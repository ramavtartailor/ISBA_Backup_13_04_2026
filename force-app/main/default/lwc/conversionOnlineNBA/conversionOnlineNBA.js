import { LightningElement, api, track, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getAccount from '@salesforce/apex/NBAConversionController.getAccount';
import getContact from '@salesforce/apex/NBAConversionController.getContact';
import getCustomerApplication from '@salesforce/apex/NBAConversionController.getCustomerApplication';
import checkRecord from '@salesforce/apex/NBAConversionController.checkRecord';
import createObject from '@salesforce/apex/NBAConversionController.createObject';
import getcurentNBA from '@salesforce/apex/NBAConversionController.getcurentNBA';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getAOP from '@salesforce/apex/NBAConversionController.getAOP';
import getPolicyQuotes from '@salesforce/apex/NBAConversionController.getPolicyQuotes';


export default class ConversionOnlineNBA extends NavigationMixin(LightningElement) {
    @api recordId;
    showaccount = false;
    @track onlineNBA;
    showcontact = false;
    showquote = false;
    showApp = false;
    showsection = '';
    accountList = [];
    contactList = [];
    policyQuotes = [];
    accountListArray = [];
    accountSearch = '';
    contactsearch = '';
    customerData = [];
    aopData = [];
    currentRecordId;
    accountName = '';
    isLoaded = false;
    selectedradiobutton = 'radio-61';
    selectedNewContacts = [];
    selectedExistingContacts = [];
    contactMap = new Map();
    customerApplicationLength;
    selectedContactLength;
    status = '';
    //@track hasAccount = false;
    selectedName;
    selectedId;
    isSelected;
    query = '';
    searchTerm;
    searchedRecords = [];
    isResult = false;
    showInfo = false;
    inputClass = '';
    isLoading = false;
    searchAccountId = '';
    boxCls = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';

    selectedNameCon;
    selectedIdCon;
    isSelectedCon;
    selectedTabCon = '';
    queryCon = '';
    searchTermCon;
    searchedRecordsCon = [];
    showInfoCon = false;
    inputClassCon = '';
    isLoadingCon = false;
    existingAccounts = false;
    createNew = true;
    // value = '';

    accountsearch(event) {
        console.log('eventacc==', event.target.value);
        this.accountSearch = event.target.value;
    }
    accName(event) {
        console.log('accname==', event.target.value);
        this.accname = event.target.value;
    }
    contactSearch(event) {
        console.log('eventacc==', event.target.value);
        this.contactsearch = event.target.value;
    }
    handleToggleSection(event) {
        this.showsection = event.detail.openSections;
        console.log('Selected Sections1 ' + event.detail.openSections);
        if (this.showsection == 'A') {
            this.showaccount = true;
        }
        else {
            this.showaccount = false;
        }
        if (this.showsection == 'B') {
            this.showcontact = true;
        }
        else {
            this.showcontact = false;
        }

    }
    firstCheck(event) {
        console.log('first==', event.target.value);
    }
    secondCheck(event) {
        console.log('secondCheck==', event.target.value);
    }
    radioaccesss(event) {
        console.log('acccreate==', event.target.value);
        this.selectedradiobutton = event.target.value;
        if (event.target.value == "radio-61") {
            this.existingAccounts = true;
            this.createNew = false;
        }
        else {
            this.existingAccounts = false;
            this.createNew = true;
        }
    }
    handleCustomerApplicatioion() {

        getCustomerApplication({ recordId: this.recordId }).then((data) => {
            console.log('testing');

            let custemerdata = [];
            if (data) {
               // this.isLoaded = true;
                let totalcountCustomer = [];
                totalcountCustomer.push(data);
                let contactList = this.contactList;
                this.customerApplicationLength = data.length;
                console.log('this.customerApplicationLength==', this.customerApplicationLength, 'data', data);
                console.log('this.contacts', this.contactList);
                let filteredIsba = [];
                data.map((list) => {
                    if (list.ISBA_Number__c && list.ARDC_Number__c) {
                        console.log('both And', list);
                        // filteredIsba = contactList.filter((listFilter)=>{return (listFilter.ISBA__c == list.ISBA_Number__c && listFilter.ARDC__c == list.ARDC_Number__c)});
                        // console.log('list',list.Id,'filteredIsba',filteredIsba);
                        // //dataObj.radioChecked    = filteredIsba.length != 0 ? true : false;


                        filteredIsba = contactList.filter((listFilter) => { return (listFilter.ISBA__c == list.ISBA_Number__c) });
                        console.log('list', list.Id, 'filteredIsba', filteredIsba);
                        //dataObj.radioChecked    = filteredIsba.length != 0 ? true : false;

                        let secondDaa = contactList.filter((listFilter) => { return (listFilter.ARDC_Number__c == list.ARDC_Number__c) });
                        console.log('ARDC', list);
                        if (secondDaa[0] !== undefined)
                            filteredIsba.push(secondDaa[0]);
                        console.log('list', list.Id, 'filteredIsba', filteredIsba);
                        //dataObj.radioChecked    = filteredIsba.length != 0 ? true : false;

                    }
                    else if (list.ISBA_Number__c) {
                        console.log('ISBA', list);
                        filteredIsba = contactList.filter((listFilter) => { return (listFilter.ISBA__c == list.ISBA_Number__c) });
                        console.log('list', list.Id, 'filteredIsba', filteredIsba);
                        //dataObj.radioChecked    = filteredIsba.length != 0 ? true : false;
                    }
                    else if (list.ARDC_Number__c) {
                        console.log('ARDC', list);
                        filteredIsba = contactList.filter((listFilter) => { return (listFilter.ARDC_Number__c == list.ARDC_Number__c) });
                        console.log('list', list.Id, 'filteredIsba', filteredIsba);
                        //dataObj.radioChecked    = filteredIsba.length != 0 ? true : false;
                    }
                    else {
                        console.log('None', list);
                        filteredIsba = [];
                    }
                    let dataObj = {};
                    dataObj.Id = list.Id;
                    dataObj.Name = list.Name + ' ' + list.Last_Name__c;
                    dataObj.ARDC_Number__c = list.ARDC_Number__c;
                    dataObj.Email = list.Firm_Email_Address__c;
                    dataObj.Hours = list.Average_Number_of_Hours_Worked__c;
                    dataObj.templateValue = filteredIsba.length != 0 ? filteredIsba[0].Name : "";
                    dataObj.templatePill = filteredIsba.length != 0 ? true : false;
                    dataObj.templateSearch = filteredIsba.length != 0 ? true : false;
                    dataObj.templateDropdown = false;
                    //  dataObj.radioChecked    = filteredIsba.length != 0 ? true : false;
                    dataObj.radioChecked = true;
                    dataObj.existingConId = filteredIsba.length != 0 ? filteredIsba[0].Id : "";
                    dataObj.existingConName = filteredIsba.length != 0 ? filteredIsba[0].Name : "";
                    dataObj.hasContact = list.Contact__c ? true : false;
                    if (dataObj.hasContact) {
                        dataObj.existingConName = list.Contact__r.Contact_Full_Name__c;
                        dataObj.existingConId = list.Contact__c;
                    }
                    else if (dataObj.existingConId && dataObj.existingConId != "") {
                        this.contactMap.set(list.Id, dataObj.existingConId);
                    }
                    dataObj.templateChk = false;
                    dataObj.checkDisable = true;
                    dataObj.existingConId != 0 ? this.selectedExistingContacts.push(dataObj.existingConId) : this.selectedExistingContacts;
                    custemerdata.push(dataObj);
                });
                this.customerData = custemerdata;
                console.log('data==', this.customerData, 'this.selectedExistingContacts', this.selectedExistingContacts);
                console.log('recId==' + this.recordId);
                this.currentRecordId = this.recordId;
                this.getNBAData();
                this.getAOPData();
                this.getPolicyQuoteData();

            }
        }).catch(error => {
            console.log('error==', error);
        });
    }
    getPolicyQuoteData() {
        getPolicyQuotes({ recordId: this.recordId })
            .then(result => {
                console.log('Policy Quotes == ', result);
                this.policyQuotes = result;
            })
            .catch(error => {
                console.log('Policy Quote error == ', error);
            });
    }

    handleCustomCheck(event) {
        console.log('event', event, event.target.value);
        let lawyerId = event.target.value;
        this.contactMap.delete(lawyerId);
        let selectedContacts = Object.assign([], this.selectedNewContacts);
        console.log('selectedContacts', selectedContacts);
        let filteredDataRecord = selectedContacts.filter((list) => { return list == event.target.value });
        console.log('selectedContacts', selectedContacts, 'filteredDataRecord', filteredDataRecord, filteredDataRecord.length);
        //  if(filteredDataRecord.length > 0){
        //      let filteredData = selectedContacts.filter((list)=>{ return list != event.target.value});
        //      this.selectedNewContacts = filteredData;
        //      console.log('inside',filteredData);
        //  }else{
        //      console.log('else');
        let filteredCustomerRecord = this.customerData.filter((list) => { return list.Id == event.target.value });
        selectedContacts.push(event.target.value);
        this.selectedNewContacts = selectedContacts;
        let customconsumer = Object.assign([], this.customerData);
        customconsumer.map((list) => {
            console.log('list.Id==', list.Id, 'event.target.value==', event.target.value);
            if (list.Id == event.target.value) {
                list.checkDisable = true;
                list.radioChecked = false;
                list.existingConId != '' ?
                    (list.templateSearch = false, list.templatePill = false, list.templateValue = '', list.existingConName = '', this.handleRemoveExistingPill(list.existingConId)) : console.log('list.existingConId ', list.existingConId);
            } else {
                list.checkDisable = !list.checkDisable ? false : true;
            }
        });
        this.customerData = customconsumer;
        //}
        this.customerData = customconsumer;
        console.log('this.selectedNewContacts', this.selectedNewContacts, 'this.customerData', this.customerData);
    }
    handleRemoveExistingPill(contId) {
        console.log('contId', contId);
        let dataFilter = this.selectedExistingContacts.filter((list) => { return list != contId });
        this.selectedExistingContacts = dataFilter;
    }
    connectedCallback() {
        this.isLoaded = false;
        console.log(' is null', this.recordId);
        this.getAccountData();
        this.getContactData();
        this.contactMap = new Map();
    }

    renderedCallback() {
        //code
        console.log('RecordId => ', this.recordId);
    }
    getAOPData() {
        getAOP({ recordId: this.recordId })
            .then(result => {
                console.log('AOP == ', result);
                this.aopData = [...result].sort((a, b) => {
                    let nameA = a.AOP_Factor__r?.Name?.toLowerCase() || '';
                    let nameB = b.AOP_Factor__r?.Name?.toLowerCase() || '';
                    return nameA.localeCompare(nameB);
                });
                this.isLoaded = true;
            })
            .catch(error => {
                console.log('AOP error == ', error);
            });
    }



    getNBAData() {
        getcurentNBA({ recordId: this.currentRecordId })
            .then(result => {
                console.log('res==', result);
                this.onlineNBA = result[0];
                this.accountName = result[0].Full_Legal_Name_of_the_Firm__c;
                this.status = result[0].Application_Status__c;

                if (result[0].Account__c) {
                    this.searchAccountId = result[0].Account__c;
                    this.selectedName = result[0].Account__r.Name;
                }
            })
            .catch(error => {
                console.log('error==', error);
            });

    }
    getAccountData() {
        getAccount({})
            .then(result => {
                console.log('res==', result);
                this.accountList = result;
                console.log('this.accountList==', this.accountList);
            })
            .catch(error => {
                console.log('error==', error);
            });

    }
    getContactData() {
        getContact({})
            .then(result => {
                console.log('res==', result);
                this.contactList = result;
                console.log('this.contactList==', this.contactList);
                if (this.recordId) {
                    checkRecord({ recId: this.recordId })
                        .then(result => {
                            if (result) {
                            }
                            else {
                                const event = new ShowToastEvent({
                                    title: 'Success!',
                                    message: 'Converted Successfully!',
                                    variant: 'success'
                                });
                                this.dispatchEvent(event);
                                this.closeQuickAction();
                            }
                        })
                        .catch(error => {
                            console.log('error==', error);
                        });
                }
                this.handleCustomerApplicatioion();
            })
            .catch(error => {
                console.log('error==', error);
            });

    }

    checkboxValue(event) {
        console.log('checkval==', this.customerData);
        let resultData = this.customerData;
        resultData.map((list) => {
            console.log('list', list);
            console.log('list.Id', this.template.querySelector(`[data-id='${list.Id}']`))
        })
        //console.log('checkval==',event);
    }

    //Account search

    onSelect(event) {
        this.selectedId = event.currentTarget.dataset.id;
        console.log('resut' + this.selectedId);
        this.searchAccountId = this.selectedId;
        this.isLoading = true;
        let selectedName = event.currentTarget.dataset.name;
        this.isSelected = true;
        this.selectedName = selectedName;
        this.boxCls = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
        this.isResult = false;
    }

    // For Search input.
    handleClick() {
        this.isResult = true;
        this.inputClass = 'slds-has-focus';
        this.boxCls = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }
    // When Remove the selected report
    handleRemovePill() {
        this.isSelected = false;
        this.isResult = false;
        this.query = '';
        this.showText = '';
    }
    // when user search for a report
    onChange(event) {
        this.searchTerm = event.target.value;
        this.searchedRecords = [];
        let dataList = [];
        this.isResult = false;
        if (this.searchTerm) {
            for (let key in this.accountList) {
                if (this.accountList[key].Name.toUpperCase().includes(this.searchTerm.toUpperCase())) {
                    dataList.push(this.accountList[key]);
                }
            }
            this.searchedRecords = dataList.slice(0, 100);
            console.log('resut' + JSON.stringify(this.searchedRecords));
            this.isResult = true;
        }
    }
    //acc search end

    //contact search

    onSelectContact(event) {
        //this.selectedIdCon = event.currentTarget.dataset.id;
        let selectedIdCon = event.currentTarget.dataset.id;
        console.log('resut' + this.selectedIdCon, JSON.stringify(event.currentTarget.dataset), event.target, event.detail, event.target.ariaLabel);
        this.isLoadingCon = true;
        let selectedName = event.currentTarget.dataset.name;
        this.isSelectedCon = true;
        let lawyerId = event.currentTarget.dataset.lawyer;
        this.contactMap.set(lawyerId, selectedIdCon);
        //this.selectedNameCon = selectedName;
        let contactId = event.target.ariaLabel;
        let customconsumer = Object.assign([], this.customerData);
        console.log('customconsumer', customconsumer);
        let dataCrossCheck = this.selectedExistingContacts.filter((listFilter) => { return listFilter == selectedIdCon });
        if (dataCrossCheck.length > 0) {
            return;
        }
        customconsumer.map((list) => {
            console.log('list.existingConId ', list.existingConId, 'list.existingConName', list.existingConName);

            if (list.templateValue != "") {
                list.existingConId = list.existingConId == "" ? selectedIdCon : list.existingConId;
                list.existingConName = list.existingConName == "" ? selectedName : list.existingConName;
                list.templatePill = true;
                list.templateSearch = true;
                list.className = ' slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
                let dataFiltered = this.selectedExistingContacts.filter((listFilter) => { return listFilter == list.existingConId });
                dataFiltered.length == 0 ? this.selectedExistingContacts.push(selectedIdCon) : this.selectedExistingContacts;
                console.log('logfinal==', this.selectedExistingContacts, dataFiltered)
            } else {
                list.existingConId = "";
                list.existingConName = "";
                list.templatePill = false;
                list.templateSearch = false;
                list.className = 'slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
            }
        });
        this.customerData = customconsumer;
        //this.boxCls = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    // For Search input.
    handleClickContact(event) {
        this.inputClassCon = 'slds-has-focus';
        this.boxCls = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
        let contactId = event.target.ariaLabel;
        let customconsumer = Object.assign([], this.customerData);
        customconsumer.map((list) => {
            if (list.Id == contactId) {
                list.className = 'slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
            } else {
                list.className = 'slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'
            }
        });
        this.customerData = customconsumer;
    }
    // When Remove the selected report
    handleRemovePillContact(event) {
        let lawyerId = event.currentTarget.dataset.lawyer;
        this.contactMap.delete(lawyerId);
        console.log(event.target, event.currentTarget.dataset.id);
        let filteredList = this.selectedExistingContacts.filter((list) => { return list != event.currentTarget.dataset.id });
        this.selectedExistingContacts = filteredList;
        console.log('this.selectedExistingContacts', this.selectedExistingContacts);
        let customconsumer = Object.assign([], this.customerData);
        customconsumer.map((list) => {
            if (list.existingConId == event.currentTarget.dataset.id) {
                list.templatePill = false;
                list.existingConId = "";
                list.existingConName = "";
                list.templateSearch = false;
                list.templateValue = "";
                list.checkDisable = false;
            }
        });
        this.customerData = customconsumer;
        // this.isSelectedCon = false;
        // this.queryCon = '';
        // this.showText = '';
    }
    // when user search for a report
    onChangeContact(event) {
        console.log('event==', event.target.value, event, event.target, event.detail);
        console.log(this.template.querySelectorAll('lightning-input'));
        let selectedContacts = Object.assign([], this.selectedNewContacts);
        console.log('selectedContacts', selectedContacts);
        let filteredDataRecord = selectedContacts.filter((list) => { return list == event.target.value });
        if (filteredDataRecord.length > 0) {
            let filteredData = selectedContacts.filter((list) => { return list != event.target.value });
            this.selectedNewContacts = filteredData;
            console.log('inside', filteredData);
        }
        let searchTermCon = event.target.value;
        let contactId = event.target.ariaLabel;
        let customconsumer = Object.assign([], this.customerData);
        if (contactId) {
            customconsumer.map((list) => {
                console.log('list.Id==', list.Id, 'Cont==', contactId);

                if (list.Id == contactId) {
                    list.templateDropdown = true;
                    list.templateValue = searchTermCon;
                    list.checkDisable = false;
                } else {
                    list.templateDropdown = false;
                    list.templateValue = list.templateValue != "" ? list.templateValue : "";
                    // list.checkDisable= list.checkDisable 
                }
            });
        }
        else {
            console.log('conditionElse', searchTermCon);
            customconsumer.map((list) => {
                if (this.selectedNewContacts.length != 0) {
                    console.log('this.selectedNewContacts.includes(list.Id)', this.selectedNewContacts.includes(list.Id));
                    this.selectedNewContacts.includes(list.Id) ? list.checkDisable = true :
                        list.Id == searchTermCon ? list.checkDisable = false : !list.checkDisable ? list.checkDisable = false : list.checkDisable = true;
                    this.selectedNewContacts.includes(list.Id) ? list.radioChecked = false :
                        list.Id == searchTermCon ? list.radioChecked = true : !list.radioChecked ? list.radioChecked = false : list.radioChecked = true;
                } else {
                    list.Id == searchTermCon ? list.checkDisable = false : !list.checkDisable ? list.checkDisable = false : true;
                    list.Id == searchTermCon ? list.radioChecked = true : !list.radioChecked ? list.radioChecked = false : true;
                }

            });
        }

        this.customerData = customconsumer;
        console.log('this.customerData', this.customerData);
        this.searchedRecordscon = [];
        let dataSet = [];
        if (searchTermCon) {
            for (let key in this.contactList) {
                if (this.contactList[key].Name.toUpperCase().includes(searchTermCon.toUpperCase())) {
                    dataSet.push(this.contactList[key]);
                }
            }
            this.searchedRecordscon = dataSet.slice(0, 10);
            console.log('resut' + JSON.stringify(this.searchedRecordscon));
        }
    }

    onSubmit() {
        //this.isLoaded = !this.isLoaded;
        console.log('this.selectedNewContacts', this.selectedNewContacts, 'this.selectedExistingContacts', this.selectedExistingContacts)
        console.log('this.selectedNewContacts', this.selectedNewContacts.length);
        console.log('this.selectedExistingContacts', this.selectedExistingContacts.length);
        this.selectedContactLength = this.selectedNewContacts.length + this.selectedExistingContacts.length;
        console.log('this.selectedContactLength==', this.selectedContactLength);
        console.log('this.customerApplicationLength==', this.customerApplicationLength);

        if (this.status === 'Incomplete' || this.status === 'Pending') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: 'Application cannot be converted while status is Incomplete or Pending.',
                    variant: 'error'
                })
            );
            return;
        }

        if (!this.searchAccountId) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: 'Please link an Account before submitting.',
                    variant: 'error'
                })
            );
            return;
        }

        if (this.onlineNBA && !this.onlineNBA.Contact__c) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: 'Please link an Contact before submitting.',
                    variant: 'error'
                })
            );
            return;
        }


        let unlinkedLawyers = this.customerData.filter(l =>
            !l.existingConId && !this.contactMap.has(l.Id)
        );

        if (unlinkedLawyers.length > 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: 'Please link all Lawyers to Contacts.',
                    variant: 'error'
                })
            );
            return;
        }

        if (!this.aopData || this.aopData.length === 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: 'Please add at least one AOP.',
                    variant: 'error'
                })
            );
            return;
        }

        let totalAop = 0;
        this.aopData.forEach(a => {
            totalAop += Number(a.Percentage__c || 0);
        });

        if (totalAop !== 100) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: 'Total AOP percentage must be exactly 100%. Current total: ' + totalAop + '%',
                    variant: 'error'
                })
            );
            return;
        }


        if (this.selectedContactLength != this.customerApplicationLength) {
            this.isLoaded = true;
            const event = new ShowToastEvent({
                title: 'Warning!',
                message: 'Please select a required Contact!',
                variant: 'warning'
            });
            this.dispatchEvent(event);
        }
        else if (this.createNew && !this.searchAccountId) {
            this.isLoaded = true;
            const event = new ShowToastEvent({
                title: 'Error!',
                message: 'Please Select an existing Account!',
                variant: 'error'
            });
            this.dispatchEvent(event);
        }
        else if (this.status == 'Converted') {
            this.isLoaded = true;
            const event = new ShowToastEvent({
                title: 'Error!',
                message: 'The Application is already converted',
                variant: 'error'
            });
            this.dispatchEvent(event);
        }
        else {
            this.isLoaded = false;
            createObject({ recordId: this.currentRecordId, newcontact: this.selectedNewContacts, searchAccount: this.searchAccountId, oldContact: this.selectedExistingContacts, lawyerContactMap: Object.fromEntries(this.contactMap) })
                .then(result => {
                    this.isLoaded = true;
                    console.log('ressultUpdate', result);
                    const event = new ShowToastEvent({
                        title: 'Success!',
                        message: 'Converted Successfully!',
                        variant: 'success'
                    });
                    this.dispatchEvent(event);
                    this.closeQuickAction();
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result,
                            actionName: 'view'
                        }
                    });
                })
                .catch(error => {
                    const event = new ShowToastEvent({
                        title: 'Error!',
                        message: error.body.message,
                        variant: 'Error'
                    });
                    this.dispatchEvent(event);
                    this.closeQuickAction();
                });
        }
    }

    closeQuickAction() {
        console.log('close');
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}