import { LightningElement, wire, track } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import getActiveOwners from '@salesforce/apex/DashboardController.getActiveOwners';
import getOpportunityStageOptions from '@salesforce/apex/DashboardController.getOpportunityStageOptions';
import DASHBOARD_FILTERS from '@salesforce/messageChannel/DashboardFilters__c';

const ALL_STAGES = [{ label: 'All stages', value: '' }];

export default class DashboardFilters extends LightningElement {
    @track startDate;
    @track endDate;
    @track ownerId;
    @track stageName;

    ownerOptions = [];
    stageOptions = ALL_STAGES;

    @wire(MessageContext)
    messageContext;

    @wire(getOpportunityStageOptions)
    wiredStageOptions({ data, error }) {
        if (error) {
            this.stageOptions = ALL_STAGES;
            return;
        }
        if (data?.length) {
            this.stageOptions = [
                ...ALL_STAGES,
                ...data.map((row) => ({
                    label: row.label || row.value,
                    value: row.value
                }))
            ];
        } else {
            this.stageOptions = ALL_STAGES;
        }
    }

    @wire(getActiveOwners)
    wiredOwners({ data, error }) {
        if (data) {
            this.ownerOptions = [{ label: 'All owners', value: '' }, ...data];
        } else if (error) {
            this.ownerOptions = [{ label: 'All owners', value: '' }];
        }
    }

    handleStartChange(event) {
        this.startDate = event.detail.value;
    }

    handleEndChange(event) {
        this.endDate = event.detail.value;
    }

    handleOwnerChange(event) {
        this.ownerId = event.detail.value;
    }

    handleStageChange(event) {
        this.stageName = event.detail.value;
    }

    handleApply() {
        this.dispatchFilter(Date.now());
    }

    handleReset() {
        this.startDate = null;
        this.endDate = null;
        this.ownerId = null;
        this.stageName = null;
        this.dispatchFilter(Date.now());
    }

    dispatchFilter(refreshToken) {
        const ownerRaw = this.ownerId;
        const stageRaw = this.stageName;
        const ownerId =
            ownerRaw != null && String(ownerRaw).trim() !== '' ? String(ownerRaw).trim() : null;
        const stageName =
            stageRaw != null && String(stageRaw).trim() !== '' ? String(stageRaw).trim() : null;
        // Always include every field so LMS does not drop null keys and partial messages overwrite filters.
        const payload = {
            startDate: this.startDate ? String(this.startDate).trim() : '',
            endDate: this.endDate ? String(this.endDate).trim() : '',
            ownerId: ownerId ?? '',
            stageName: stageName ?? '',
            refreshToken
        };
        publish(this.messageContext, DASHBOARD_FILTERS, payload);
        this.dispatchEvent(
            new CustomEvent('filterchange', {
                detail: payload,
                bubbles: true,
                composed: true
            })
        );
    }
}