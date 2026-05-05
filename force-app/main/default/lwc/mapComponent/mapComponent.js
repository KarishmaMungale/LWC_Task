import { LightningElement, api } from 'lwc';
import leaflet from '@salesforce/resourceUrl/leaflet';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

export default class MapComponent extends LightningElement {
    @api opportunities;
    initialized = false;

    renderedCallback() {
        if (this.initialized) return;
        this.initialized = true;

        Promise.all([
            loadScript(this, leaflet + '/leaflet.js'),
            loadStyle(this, leaflet + '/leaflet.css')
        ]).then(() => this.initMap());
    }

    initMap() {
        const map = L.map(this.template.querySelector('.map')).setView([20.5937, 78.9629], 5);

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(map);

        this.opportunities.forEach(o => {
            if (o.Account?.BillingLatitude && o.Account?.BillingLongitude) {
                L.marker([o.Account.BillingLatitude, o.Account.BillingLongitude])
                    .addTo(map)
                    .bindPopup(o.Account.Name);
            }
        });
    }
}