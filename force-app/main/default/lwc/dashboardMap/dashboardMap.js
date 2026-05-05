import { LightningElement, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import LEAFLET from '@salesforce/resourceUrl/LwcDashboardLeaflet';

export default class DashboardMap extends LightningElement {
    @api locations = [];
    @api summary;

    get hasLocations() {
        return Array.isArray(this.locations) && this.locations.length > 0;
    }

    leafletReady = false;
    mapInstance;
    lastDigest;

    renderedCallback() {
        const digest = JSON.stringify(this.locations);
        if (digest === this.lastDigest && this.mapInstance) {
            return;
        }
        this.lastDigest = digest;

        if (!this.leafletReady) {
            Promise.all([loadScript(this, `${LEAFLET}/leaflet.js`), loadStyle(this, `${LEAFLET}/leaflet.css`)])
                .then(() => {
                    this.leafletReady = true;
                    this.bootstrapMap();
                })
                .catch(() => undefined);
        } else {
            this.bootstrapMap();
        }
    }

    disconnectedCallback() {
        this.destroyMap();
    }

    destroyMap() {
        if (this.mapInstance) {
            this.mapInstance.remove();
            this.mapInstance = undefined;
        }
    }

    bootstrapMap() {
        // eslint-disable-next-line no-undef
        const leaflet = window.L;
        if (!leaflet) {
            return;
        }

        this.destroyMap();

        const container = this.template.querySelector('.leaflet-root');
        if (!container) {
            return;
        }

        const coords = (this.locations || [])
            .map((row) => ({
                lat: Number(row.latitude),
                lng: Number(row.longitude),
                label: row.name
            }))
            .filter((row) => Number.isFinite(row.lat) && Number.isFinite(row.lng));

        if (!coords.length) {
            return;
        }

        const map = leaflet.map(container, { zoomControl: true, scrollWheelZoom: false });
        this.mapInstance = map;

        leaflet
            .tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; OpenStreetMap',
                maxZoom: 18
            })
            .addTo(map);

        const layer = leaflet.layerGroup().addTo(map);
        const bounds = [];
        coords.forEach((point) => {
            leaflet
                .circleMarker([point.lat, point.lng], {
                    radius: 7,
                    color: '#0176d3',
                    weight: 2,
                    fillColor: '#78b4f8',
                    fillOpacity: 0.85
                })
                .bindPopup(`<strong>${point.label}</strong>`)
                .addTo(layer);
            bounds.push([point.lat, point.lng]);
        });

        map.fitBounds(bounds, { padding: [24, 24], maxZoom: 12 });
    }
}