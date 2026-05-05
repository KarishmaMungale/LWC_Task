import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import FILTER_CHANNEL from '@salesforce/messageChannel/filterMessage__c';

export default class FilterPanel extends LightningElement {

    @wire(MessageContext)
    messageContext;

    stageOptions = [
        { label: 'Prospecting', value: 'Prospecting' },
        { label: 'Closed Won', value: 'Closed Won' }
    ];

    handleStage(event) {
        this.publish({ stage: event.detail.value });
    }

    handleStart(event) {
        this.publish({ startDate: event.detail.value });
    }

    handleEnd(event) {
        this.publish({ endDate: event.detail.value });
    }

    publish(payload) {
        publish(this.messageContext, FILTER_CHANNEL, payload);
    }
}