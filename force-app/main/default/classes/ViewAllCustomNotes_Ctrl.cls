public class ViewAllCustomNotes_Ctrl {
    public List<Note__c> notesList{get;set;}
    public String recordName{get;set;}
    public String objectType{get;set;}
    
    public ViewAllCustomNotes_Ctrl(){
        notesList = new List<Note__c>();
        Id objectId = ApexPages.currentPage().getParameters().get('Id');
        objectType = ApexPages.currentPage().getParameters().get('obj');
        if(objectType=='Policy'){
            Policy__C policy = [select name,Account__r.Name from Policy__C where id = : objectId][0];
            recordName = policy.Account__r.Name + ' - ' + policy.name;
            notesList = [select id,name,Subject__C,Type__C,CreatedDate,CreatedBy.Name,Description__C from Note__C where Policy__C = : objectId ORDER BY CreatedDate DESC limit 1000];
        }else if(objectType=='Claim'){
            Policy_Claim__C claim = [select name,Policy__r.Name,Policy__r.Account__r.Name from Policy_Claim__C where id = : objectId][0];
            recordName = claim.Policy__r.Account__r.Name + ' - ' + claim.Policy__r.Name + ' - ' + claim.name;
            notesList = [select id,name,Subject__C,Type__C,CreatedDate,CreatedBy.Name,Description__C from Note__C where Claim__C = : objectId ORDER BY CreatedDate DESC limit 1000];
        }
        else if(objectType=='Account'){
            //Policy_Claim__C claim = [select name,Policy__r.Name,Policy__r.Account__r.Name from Policy_Claim__c where id = : objectId][0];
            //recordName = claim.Policy__r.Account__r.Name + ' - ' + claim.Policy__r.Name + ' - ' + claim.name;
            notesList = [select id,name,Subject__C,Type__c,CreatedDate,CreatedBy.Name,Description__c from Note__c where Account__c = : objectId ORDER BY CreatedDate DESC limit 1000];
            
            
        }
    }
}