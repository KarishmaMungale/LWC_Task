import { LightningElement, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import CHARTJS from '@salesforce/resourceUrl/LwcDashboardChartJs';

export default class DashboardCharts extends LightningElement {
    @api metrics;

    chartJsInitialized = false;
    doughnutChart;
    barChart;
    lastDigest;
    digestToApply;

    renderedCallback() {
        if (!this.metrics) {
            return;
        }
        const digest = JSON.stringify(this.metrics);
        if (digest === this.lastDigest) {
            return;
        }
        this.digestToApply = digest;

        if (!this.chartJsInitialized) {
            loadScript(this, `${CHARTJS}/ChartJs.js`)
                .then(() => {
                    this.chartJsInitialized = true;
                    this.applyCharts(this.digestToApply);
                })
                .catch(() => undefined);
        } else {
            this.applyCharts(digest);
        }
    }

    disconnectedCallback() {
        this.teardownCharts();
    }

    teardownCharts() {
        if (this.doughnutChart) {
            this.doughnutChart.destroy();
            this.doughnutChart = undefined;
        }
        if (this.barChart) {
            this.barChart.destroy();
            this.barChart = undefined;
        }
    }

    applyCharts(digest) {
        // eslint-disable-next-line no-undef
        const ChartCtor = window.Chart;
        if (!ChartCtor || !this.metrics) {
            return;
        }

        this.teardownCharts();
        this.lastDigest = digest;

        const doughnutCanvas = this.template.querySelector('canvas.doughnut');
        const barCanvas = this.template.querySelector('canvas.bar');

        const open = this.metrics.openCount || 0;
        const won = this.metrics.wonCount || 0;
        const lost = this.metrics.lostCount || 0;

        if (doughnutCanvas) {
            this.doughnutChart = new ChartCtor(doughnutCanvas, {
                type: 'doughnut',
                data: {
                    labels: ['Open', 'Won', 'Lost'],
                    datasets: [
                        {
                            data: [open, won, lost],
                            backgroundColor: ['#1589EE', '#2E844A', '#C23934'],
                            borderWidth: 1
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { position: 'bottom' },
                        title: { display: true, text: 'Pipeline outcomes' }
                    }
                }
            });
        }

        const slices = Array.isArray(this.metrics.stageSlices) ? this.metrics.stageSlices : [];
        const labels = slices.map((row) => row.stageName || 'Unspecified');
        const amounts = slices.map((row) => Number(row.totalAmount || 0));

        if (barCanvas) {
            this.barChart = new ChartCtor(barCanvas, {
                type: 'bar',
                data: {
                    labels,
                    datasets: [{ label: 'Open amount by stage', data: amounts, backgroundColor: '#706E6B' }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false },
                        title: { display: true, text: 'Amount by open stage' }
                    },
                    scales: {
                        x: { ticks: { autoSkip: true, maxTicksLimit: 8 } },
                        y: { beginAtZero: true }
                    }
                }
            });
        }
    }
}