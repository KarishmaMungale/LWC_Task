import { LightningElement } from 'lwc';

export default class DashboardCard extends LightningElement {
    get cardClass() {
        return 'slds-card slds-card_boundary dashboard-card';
    }
}