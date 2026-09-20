import { LightningElement, wire } from 'lwc';
import getRequests from '@salesforce/apex/ServiceRequestController.getRequests';
import searchRequests from '@salesforce/apex/ServiceRequestController.searchRequests';

export default class ServiceOpsDashboard extends LightningElement {

    requests;
    searchTerm = '';

    @wire(getRequests)
    wiredRequests({ data, error }) {

        if (data) {
            this.requests = data;
        } else if (error) {
            console.error('Error loading service requests:', error);
            this.requests = [];
        }
    }

    async handleSearch(event) {

        this.searchTerm = event.target.value;

        if (!this.searchTerm.trim()) {
            this.loadRequests();
            return;
        }

        try {
            this.requests =
                await searchRequests({
                    searchTerm: this.searchTerm
                });
        } catch (error) {
            console.error('Search error:', error);
            this.requests = [];
        }
    }

    async loadRequests() {

        try {
            this.requests = await getRequests();
        } catch (error) {
            console.error('Error loading requests:', error);
            this.requests = [];
        }
    }
}