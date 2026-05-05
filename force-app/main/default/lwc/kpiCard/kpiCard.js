import { LightningElement, api } from 'lwc';

export default class KpiCard extends LightningElement {
    @api title;
    @api value;

    get cardClass() {
        return this.value > 100000 ? 'card green' : 'card red';
    }
}