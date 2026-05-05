public with sharing class DeleteQuotesCtrl {
    public String selectedQuotes{ get; set; }
    
    public Class DeleteQuotesCtrlException Extends Exception{}

    public DeleteQuotesCtrl(ApexPages.StandardSetController stdController) {
        // Initialize standard set controller for bulk record handling
        selectedQuotes = '';
        for(Policy_Quote__c q : (List<Policy_Quote__c>)stdController.getSelected()){
            selectedQuotes += q.Id+',';
        }
        if(selectedQuotes.endsWith(',')){
            selectedQuotes = selectedQuotes.removeEnd(',');
        }
    }

    @AuraEnabled
    public Static Boolean deleteQuotes(String quoteIds){
        try{
            List<Policy_Quote__c> quoteList = new List<Policy_Quote__c>();
            for(String qId : quoteIds.split(',')){
                quoteList.add(new Policy_Quote__c(Id = qId.trim()));
            }
            Delete quoteList;
            return true;
        }
        Catch(DmlException e){
            throw new DeleteQuotesCtrlException(e.getDmlMessage(0));
        }
    }
}