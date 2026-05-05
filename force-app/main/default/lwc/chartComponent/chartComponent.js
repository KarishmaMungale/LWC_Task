import { LightningElement, api } from 'lwc';
import chartjs from '@salesforce/resourceUrl/chartjs';
import { loadScript } from 'lightning/platformResourceLoader';

export default class ChartComponent extends LightningElement {
    @api opportunities;
    chartInitialized = false;

    renderedCallback() {
    if (this.chartInitialized) return;

    loadScript(this, chartjs + '/Chart.min.js')
        .then(() => {
            console.log('Chart loaded:', window.Chart); // debug
            this.chartInitialized = true;
            this.renderChart();
        })
        .catch(error => {
            console.error('Error loading chart', error);
        });
}

    renderChart() {
        const ctx = this.template.querySelector('canvas').getContext('2d');

        const stageMap = {};
        this.opportunities.forEach(o => {
            stageMap[o.StageName] = (stageMap[o.StageName] || 0) + 1;
        });

        new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: Object.keys(stageMap),
                datasets: [{
                    label: 'Opportunities',
                    data: Object.values(stageMap)
                }]
            }
        });
    }
}