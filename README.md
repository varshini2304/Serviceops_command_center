# ServiceOps Command Center

[![Salesforce DX](https://img.shields.io/badge/Salesforce-DX-blue.svg)](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/)
[![API Version](https://img.shields.io/badge/API%20Version-67.0-brightgreen.svg)](https://developer.salesforce.com/docs)
[![LWC](https://img.shields.io/badge/UI-Lightning%20Web%20Components-yellow.svg)](https://developer.salesforce.com/docs/component-library/overview/components)
[![Code Style](https://img.shields.io/badge/Code%20Style-Prettier%20%2B%20ESLint-orange.svg)](https://prettier.io/)

**ServiceOps Command Center** is an end-to-end Salesforce operations management solution built to streamline service request tracking, automated SLA monitoring, escalation handling, and incident triage.

---

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Architecture & Data Model](#architecture--data-model)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
  - [1. Clone and Install Dependencies](#1-clone-and-install-dependencies)
  - [2. Authenticate to Salesforce](#2-authenticate-to-salesforce)
  - [3. Create a Scratch Org (Optional)](#3-create-a-scratch-org-optional)
  - [4. Deploy Metadata](#4-deploy-metadata)
- [Apex Automation & Batch Jobs](#apex-automation--batch-jobs)
- [Testing & Quality Assurance](#testing--quality-assurance)
  - [Running LWC Unit Tests](#running-lwc-unit-tests)
  - [Running Apex Tests](#running-apex-tests)
  - [Code Formatting and Linting](#code-formatting-and-linting)
- [Useful Salesforce CLI Commands](#useful-salesforce-cli-commands)
- [License](#license)

---

## Overview

Modern support and IT operations demand rapid triage, transparent SLA tracking, and reliable automation. The **ServiceOps Command Center** equips service managers and agents with:
- A responsive **Lightning Web Component (LWC)** dashboard for real-time visibility.
- Instant search and filtering across tickets using **SOSL**.
- Asynchronous Apex jobs for automated **SLA breach detection and escalation**.
- A scalable trigger and service framework adhering to enterprise design patterns.

---

## Key Features

- **Service Request Tracking**: Custom data model capturing Subject, Priority, Status, Category, SLA Due datetime, Escalation state, and Account/Contact/Owner relationships.
- **ServiceOps Command Center Dashboard (`serviceOpsDashboard`)**:
  - Real-time card-based view of open service requests.
  - Interactive search bar powered by SOSL for finding requests across all fields.
  - SLDS (Salesforce Lightning Design System) compliant UI.
- **Automated SLA Monitoring (`ServiceRequestBatch`)**:
  - Scheduled batch job inspecting active requests against `SLA_Due__c`.
  - Automatically flags overdue tickets with `Is_Escalated__c = true`.
- **High-Priority Queueable Escalations (`ServiceRequestQueueable`)**:
  - Asynchronous background worker to process Critical/High priority requests immediately.
- **Enterprise Trigger Framework**:
  - Trigger orchestration via `ServiceRequestTrigger` and `ServiceRequestTriggerHandler` with logic encapsulated in `ServiceRequestService`.
- **System Logging**: `Service_Log__c` custom object for tracking operational events and auditing.

---

## Architecture & Data Model

### Custom Objects

- **`Service_Request__c`**: Core record representing support tickets and operational tasks.
  - `Subject__c` (Text)
  - `Description__c` (Long Text)
  - `Status__c` (Picklist: New, In Progress, Pending, Resolved, Closed, etc.)
  - `Priority__c` (Picklist: Low, Medium, High, Critical)
  - `Category__c` (Picklist)
  - `SLA_Due__c` (DateTime)
  - `Resolved_Date__c` (DateTime)
  - `Is_Escalated__c` (Checkbox)
  - `Account__c` (Lookup to Account)
  - `Contact__c` (Lookup to Contact)
  - `Assigned_To__c` (Lookup to User)
- **`Service_Log__c`**: Audit trail and operational diagnostic logging.

### Component Relationship

```
+-------------------------------------------------------------+
|                  Lightning Web Component                    |
|                   serviceOpsDashboard                       |
+------------------------------+------------------------------+
                               | Wire / Imperative Calls
                               v
+-------------------------------------------------------------+
|                     Apex Controller                         |
|                 ServiceRequestController                    |
+------------------------------+------------------------------+
                               |
           +-------------------+-------------------+
           |                                       |
           v                                       v
+----------------------+               +----------------------+
|  Service_Request__c  | <-----------+ | ServiceRequestBatch  |
|       (Object)       |               | (Scheduled Daily)    |
+----------+-----------+               +----------------------+
           |                                       ^
           v Trigger                               | Scheduled by
+----------------------+               +----------------------+
| ServiceRequestTrigger|               |ServiceRequestScheduler
+----------+-----------+               +----------------------+
           |
           v
+------------------------------+
| ServiceRequestTriggerHandler |
+--------------+---------------+
               |
               v
+------------------------------+
|    ServiceRequestService     |
+--------------+---------------+
               | High/Critical Priority
               v
+------------------------------+
|    ServiceRequestQueueable   |
+------------------------------+
```

---

## Project Structure

```
serviceops-command-center/
├── config/
│   └── project-scratch-def.json        # Scratch org definition configuration
├── force-app/main/default/
│   ├── classes/                        # Apex classes (Controllers, Batch, Queueable, Tests)
│   │   ├── ServiceRequestBatch.cls
│   │   ├── ServiceRequestBatchTest.cls
│   │   ├── ServiceRequestController.cls
│   │   ├── ServiceRequestControllerTest.cls
│   │   ├── ServiceRequestQueueable.cls
│   │   ├── ServiceRequestQueueableTest.cls
│   │   ├── ServiceRequestScheduler.cls
│   │   ├── ServiceRequestSchedulerTest.cls
│   │   ├── ServiceRequestService.cls
│   │   ├── ServiceRequestServiceTest.cls
│   │   ├── ServiceRequestTriggerHandler.cls
│   │   └── ...
│   ├── lwc/                            # Lightning Web Components
│   │   └── serviceOpsDashboard/        # Dashboard component & Jest tests
│   │       ├── __tests__/
│   │       ├── serviceOpsDashboard.html
│   │       ├── serviceOpsDashboard.js
│   │       └── serviceOpsDashboard.js-meta.xml
│   ├── objects/                        # Custom object definitions & fields
│   │   ├── Service_Log__c/
│   │   └── Service_Request__c/
│   └── triggers/                       # Apex Triggers
│       ├── ServiceRequestTrigger.trigger
│       └── ServiceRequestTrigger.trigger-meta.xml
├── package.json                        # Node dependencies and npm scripts
├── sfdx-project.json                   # Salesforce DX configuration (API 67.0)
├── .eslintrc.json / eslint.config.js   # ESLint rules for LWC
└── README.md                           # Documentation
```

---

## Prerequisites

Before setting up the project, ensure you have installed:

1. **[Node.js](https://nodejs.org/)** (v18 or higher recommended)
2. **[Salesforce CLI (`sf`)](https://developer.salesforce.com/tools/salesforcecli)**:
   ```bash
   sf version
   ```
3. **[Visual Studio Code](https://code.visualstudio.com/)** with the **[Salesforce Extension Pack](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode)**.

---

## Getting Started

### 1. Clone and Install Dependencies

```bash
git clone https://github.com/varshini2304/Serviceops_command_center.git
cd serviceops-command-center
npm install
```

### 2. Authenticate to Salesforce

Log in to your Salesforce Developer Hub or Target Org:

```bash
sf org login web -d -a DevHub
```

### 3. Create a Scratch Org (Optional)

If developing in a scratch org:

```bash
sf org create scratch -d -f config/project-scratch-def.json -a serviceops-scratch --set-default
```

### 4. Deploy Metadata

Deploy all project source metadata to your active org:

```bash
sf project deploy start
```

Open your org in the browser:

```bash
sf org open
```

---

## Apex Automation & Batch Jobs

### Schedule SLA Breach Monitoring

To run the `ServiceRequestScheduler` every hour to automatically escalate overdue requests:

```apex
// Execute in Anonymous Apex (sf apex run)
String cronExp = '0 0 * * * ?'; // Hourly
System.schedule('ServiceRequest SLA Monitor', cronExp, new ServiceRequestScheduler());
```

### Run Batch Manually

```apex
// Execute in Anonymous Apex (sf apex run)
Database.executeBatch(new ServiceRequestBatch(), 100);
```

---

## Testing & Quality Assurance

### Running LWC Unit Tests

Run LWC Jest tests with code coverage reporting:

```bash
# Run all Jest tests
npm run test:unit

# Run Jest tests with coverage
npm run test:unit:coverage

# Run Jest in watch mode
npm run test:unit:watch
```

### Running Apex Tests

Execute all Apex test classes and retrieve code coverage:

```bash
sf apex run test --test-level RunLocalTests --code-coverage --result-format human
```

To run a specific test class:

```bash
sf apex run test -n ServiceRequestControllerTest --code-coverage --result-format human
```

### Code Formatting and Linting

Validate code consistency across Apex, LWC, XML, and JSON files:

```bash
# Format code with Prettier
npm run prettier

# Verify formatting without modifying files
npm run prettier:verify

# Lint Lightning Web Components
npm run lint
```

---

## Useful Salesforce CLI Commands

| Command | Description |
|---|---|
| `sf project deploy start` | Deploys source metadata to the default org |
| `sf project retrieve start` | Retrieves source metadata from the default org |
| `sf apex run` | Executes anonymous Apex from terminal or file |
| `sf apex run test` | Runs Apex test classes and shows code coverage |
| `sf org open` | Opens the default org in your browser |
| `sf org list` | Lists all authorized Salesforce orgs |

---

## License

This project is licensed under the [MIT License](LICENSE).
