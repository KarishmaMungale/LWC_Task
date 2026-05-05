import { LightningElement, wire, track } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import FILTER_CHANNEL from '@salesforce/messageChannel/filterMessage__c';
import getOpportunities from '@salesforce/apex/DashboardController.getOpportunities';

export default class DashboardContainer extends LightningElement {
    @track opportunities = [];
    filters = {};

    subscription;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToMessageChannel();
        this.loadData();
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            FILTER_CHANNEL,
            (message) => this.handleFilterChange(message)
        );
    }

    handleFilterChange(message) {
        this.filters = { ...this.filters, ...message };
        this.loadData();
    }

    loadData() {
        getOpportunities({
            stage: this.filters.stage,
            startDate: this.filters.startDate,
            endDate: this.filters.endDate
        })
        .then(result => {
            this.opportunities = result;
        })
        .catch(error => {
            console.error(error);
        });
    }

    get totalRevenue() {
        return this.opportunities.reduce((sum, opp) => sum + (opp.Amount || 0), 0);
    }

    get totalOpps() {
        return this.opportunities.length;
    }

    get closedWon() {
        return this.opportunities.filter(o => o.StageName === 'Closed Won').length;
    }
}