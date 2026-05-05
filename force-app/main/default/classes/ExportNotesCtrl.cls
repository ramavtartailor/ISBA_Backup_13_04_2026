public class ExportNotesCtrl {
    public List<Note__c> notesList{get;set;}
    public ExportNotesCtrl(){
        Id recordId = ApexPages.CurrentPage().getParameters().get('recordId');
        String selectedFilterValue = ApexPages.CurrentPage().getParameters().get('selectedFilterValue');
        String selectedNoteTypeFilterValue = ApexPages.CurrentPage().getParameters().get('selectedNoteTypeFilterValue');
        System.debug('recordId---'+recordId);
        String objName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        if(objName == 'Account'){
            List<Policy__C> lstPolicies = [select id,Account__c from Policy__c where Account__C=:recordId ];
            if(selectedNoteTypeFilterValue == 'ALL' || String.isBlank(selectedNoteTypeFilterValue)){
                notesList = new List<Note__c>([select id,Name,Type__C,Status__C,Subject__c,Description__C,CreatedDate,Created_By_Name__c,of_Attachments__c from Note__C where Account__c=:recordId OR Policy__C in : lstPolicies order by createdDate desc]);
            }else{
                notesList = new List<Note__c>([select id,Name,Type__C,Status__C,Subject__c,Description__C,CreatedDate,Created_By_Name__c,of_Attachments__c from Note__C where (Account__c=:recordId OR Policy__C in : lstPolicies) AND Type__c =:selectedNoteTypeFilterValue order by createdDate desc]);
            }
            
        }else if(objName == 'Policy__c'){
            if(selectedFilterValue == 'View This Policy Notes'){
                if(selectedNoteTypeFilterValue == 'ALL' || String.isBlank(selectedNoteTypeFilterValue)){
                    notesList = new List<Note__c>([select id,Name,Type__C,Status__C,Subject__c,Description__C,CreatedDate,Created_By_Name__c,of_Attachments__c from Note__C where Policy__C = : recordId  order by createdDate desc]);
                }else{
                    notesList = new List<Note__c>([select id,Name,Type__C,Status__C,Subject__c,Description__C,CreatedDate,Created_By_Name__c,of_Attachments__c from Note__C where Policy__C = : recordId AND Type__c =:selectedNoteTypeFilterValue order by createdDate desc]);
                }
            }else{
                List<Policy__C> lstPolicies = [select id,Account__c from Policy__c where Id=:recordId ];
                if(lstPolicies.size()>0 && lstPolicies[0].Account__C!=null){
                    lstPolicies = [select id,Account__c from Policy__c where Account__C=:lstPolicies[0].Account__C ];
                    if(selectedNoteTypeFilterValue == 'ALL' || String.isBlank(selectedNoteTypeFilterValue)){
                        notesList = new List<Note__c>([select id,Name,Type__C,Status__C,Subject__c,Description__C,CreatedDate,Created_By_Name__c,of_Attachments__c from Note__C where  Policy__C in : lstPolicies OR Account__c =: lstPolicies[0].Account__C  order by createdDate desc]);
                    }else{
                        notesList = new List<Note__c>([select id,Name,Type__C,Status__C,Subject__c,Description__C,CreatedDate,Created_By_Name__c,of_Attachments__c from Note__C where  (Policy__C in : lstPolicies OR Account__c =: lstPolicies[0].Account__C) AND Type__c =:selectedNoteTypeFilterValue order by createdDate desc]);
                    }
                }else{
                    if(selectedNoteTypeFilterValue == 'ALL' || String.isBlank(selectedNoteTypeFilterValue)){
                        notesList = new List<Note__c>([select id,Name,Type__C,Status__C,Subject__c,Description__C,CreatedDate,Created_By_Name__c,of_Attachments__c from Note__C where (Policy__C = : recordId  OR Account__c =: lstPolicies[0].Account__C) order by createdDate desc]);
                    }else{
                        notesList = new List<Note__c>([select id,Name,Type__C,Status__C,Subject__c,Description__C,CreatedDate,Created_By_Name__c,of_Attachments__c from Note__C where (Policy__C = : recordId OR Account__c =: lstPolicies[0].Account__C) AND Type__c =:selectedNoteTypeFilterValue order by createdDate desc]);
                    }
                }
            }
        }else if(objName == 'Policy_Claim__c'){
            if(selectedNoteTypeFilterValue == 'ALL' || String.isBlank(selectedNoteTypeFilterValue)){
                notesList = new List<Note__c>([select id,Name,Type__C,Status__C,Subject__c,Description__C,CreatedDate,Created_By_Name__c,of_Attachments__c from Note__C where Claim__c=:recordId  order by createdDate desc]);
            }else{
                notesList = new List<Note__c>([select id,Name,Type__C,Status__C,Subject__c,Description__C,CreatedDate,Created_By_Name__c,of_Attachments__c from Note__C where Claim__c=:recordId AND Type__c =:selectedNoteTypeFilterValue  order by createdDate desc]);
            }
        }else{
            notesList = new List<Note__c>();
        }
    }
}