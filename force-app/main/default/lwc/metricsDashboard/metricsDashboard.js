import { LightningElement, wire, track } from 'lwc';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import getDashboardMetrics from '@salesforce/apex/DashboardController.getDashboardMetrics';
import getAccountLocations from '@salesforce/apex/DashboardController.getAccountLocations';
import DASHBOARD_FILTERS from '@salesforce/messageChannel/DashboardFilters__c';

function blankToNull(value) {
    if (value == null) {
        return null;
    }
    const s = String(value).trim();
    return s === '' ? null : s;
}

function filterEnvelopeEqual(a, b) {
    if (!a || !b) {
        return false;
    }
    return (
        a.startDate === b.startDate &&
        a.endDate === b.endDate &&
        a.ownerId === b.ownerId &&
        a.stageName === b.stageName &&
        a.refreshToken === b.refreshToken
    );
}

function isCanceledOrDisconnected(error) {
    if (!error) {
        return false;
    }
    let bodyMsg;
    if (typeof error.body === 'string') {
        try {
            bodyMsg = JSON.parse(error.body)?.message;
        } catch (e) {
            bodyMsg = error.body;
        }
    } else {
        bodyMsg = error.body?.message;
    }
    const msg = String(bodyMsg || error.message || '');
    return /Disconnected|Canceled/i.test(msg);
}

export default class MetricsDashboard extends LightningElement {
    subscription;
    metricsRequestId = 0;
    metricsDebounceTimer;
    didResolveEmbeddedFilters;

    @track filterEnvelope = {
        startDate: null,
        endDate: null,
        ownerId: null,
        stageName: null,
        refreshToken: 0
    };

    @track metrics;
    @track metricsError;
    @track locationResult;
    @track locationError;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscription = subscribe(this.messageContext, DASHBOARD_FILTERS, (message) =>
            this.handleExternalFilter(message)
        );
        this.scheduleMetricsRefresh();
    }

    renderedCallback() {
        if (this.didResolveEmbeddedFilters) {
            return;
        }
        this.didResolveEmbeddedFilters = true;
        const embedded = this.template.querySelector('c-dashboard-filters');
        if (embedded && this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = undefined;
        }
    }

    disconnectedCallback() {
        if (this.metricsDebounceTimer) {
            clearTimeout(this.metricsDebounceTimer);
            this.metricsDebounceTimer = undefined;
        }
        this.metricsRequestId += 1;
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = undefined;
        }
    }

    handleExternalFilter(message) {
        const m = message || {};
        const prev = this.filterEnvelope;
        const next = {
            startDate: 'startDate' in m ? blankToNull(m.startDate) : prev.startDate,
            endDate: 'endDate' in m ? blankToNull(m.endDate) : prev.endDate,
            ownerId: 'ownerId' in m ? blankToNull(m.ownerId) : prev.ownerId,
            stageName: 'stageName' in m ? blankToNull(m.stageName) : prev.stageName,
            refreshToken: m.refreshToken != null ? Number(m.refreshToken) : Date.now()
        };
        if (filterEnvelopeEqual(this.filterEnvelope, next)) {
            return;
        }
        this.filterEnvelope = next;
        this.scheduleMetricsRefresh();
    }

    scheduleMetricsRefresh() {
        if (this.metricsDebounceTimer) {
            clearTimeout(this.metricsDebounceTimer);
        }
        this.metricsDebounceTimer = setTimeout(() => {
            this.metricsDebounceTimer = undefined;
            this.refreshMetrics();
        }, 75);
    }

    handleFilterFromChild(event) {
        this.handleExternalFilter(event.detail);
    }

    toPlainFilters() {
        const f = this.filterEnvelope;
        return {
            startDate: f.startDate ?? null,
            endDate: f.endDate ?? null,
            ownerId: f.ownerId ?? null,
            stageName: f.stageName ?? null,
            refreshToken: f.refreshToken != null ? Number(f.refreshToken) : 0
        };
    }

    async refreshMetrics() {
        const requestId = ++this.metricsRequestId;
        this.metricsError = undefined;
        const filters = this.toPlainFilters();
        try {
            const data = await getDashboardMetrics({
                startDate: filters.startDate,
                endDate: filters.endDate,
                ownerId: filters.ownerId,
                stageName: filters.stageName,
                refreshToken: filters.refreshToken
            });
            if (requestId !== this.metricsRequestId) {
                return;
            }
            this.metrics = data;
            this.metricsError = undefined;
        } catch (error) {
            if (isCanceledOrDisconnected(error)) {
                return;
            }
            if (requestId !== this.metricsRequestId) {
                return;
            }
            this.metricsError = error;
            this.metrics = undefined;
        }
    }

    @wire(getAccountLocations, { filters: '$filterEnvelope', rowLimit: 500, rowOffset: 0 })
    wiredLocations({ data, error }) {
        if (error) {
            this.locationError = error;
            this.locationResult = undefined;
            return;
        }
        if (data) {
            this.locationResult = data;
            this.locationError = undefined;
        }
    }

    get mapLocations() {
        return this.locationResult?.records || [];
    }

    get mapSummary() {
        if (!this.locationResult) {
            return '';
        }
        const total = this.locationResult.totalWithGeo || 0;
        const shown = this.mapLocations.length;
        const truncated = this.locationResult.truncated ? ' Results trimmed to 500 accounts for performance.' : '';
        return `Showing ${shown} of ${total} geocoded accounts.${truncated}`;
    }

    get isBusy() {
        return !this.metrics && !this.metricsError;
    }

    get hasMetrics() {
        return Boolean(this.metrics);
    }

    get openPipelineClass() {
        const amount = Number(this.metrics?.openAmount || 0);
        if (amount >= 1000000) {
            return 'slds-text-heading_medium slds-text-color_success';
        }
        if (amount <= 0) {
            return 'slds-text-heading_medium slds-text-color_weak';
        }
        return 'slds-text-heading_medium slds-text-color_default';
    }

    get winRateRatio() {
        const won = Number(this.metrics?.wonCount || 0);
        const lost = Number(this.metrics?.lostCount || 0);
        const d = won + lost;
        return d ? won / d : 0;
    }

    get wonPulseClass() {
        const ratio = this.winRateRatio;
        if (ratio >= 0.45) {
            return 'metric-chip metric-chip_positive';
        }
        if (ratio <= 0.15) {
            return 'metric-chip metric-chip_negative';
        }
        return 'metric-chip metric-chip_neutral';
    }

    get winRateDisplay() {
        return `${(this.winRateRatio * 100).toFixed(1)}%`;
    }

    get showMapWarning() {
        return Boolean(this.locationResult?.truncated);
    }
}