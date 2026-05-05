public class AccountNotesWrapper implements Comparable{
    @AuraEnabled
    public String name{get;set;}
    @AuraEnabled
    public String noteType{get;set;}
    @AuraEnabled
    public String status{get;set;}
    @AuraEnabled
    public String subject{get;set;}
    @AuraEnabled
    public String description{get;set;}
    @AuraEnabled
    public Id ids{get;set;}
    @AuraEnabled
    public Date createdDate{get;set;}
    @AuraEnabled
    public String createdByName{get;set;}
    @AuraEnabled
    public Decimal numberOfAttachments{get;set;}
    public static String sortBy = 'CreatedDate';
    public static String sortType = 'DESC';
    public AccountNotesWrapper(String name,String noteType,String subject,String description,Id ids,Date createdDate,String createdByName,Decimal numberOfAttachments){
        this.name = name;
        this.noteType = noteType;
        this.subject = subject;
        this.description = description;
        this.ids = ids;
        this.createdDate = createdDate;
        this.createdByName = createdByName;
        this.numberOfAttachments = numberOfAttachments;
    }
    public Integer compareTo(Object objToCompare){
        Integer returnInteger;
        if(sortBy == 'Name'){
            returnInteger =  name.compareTo(((AccountNotesWrapper)objToCompare).name);
        }else if(sortBy == 'Created_By_Name__c'){
            returnInteger =  createdByName.compareTo(((AccountNotesWrapper)objToCompare).createdByName);
        }else if(sortBy == 'Type__C'){
            returnInteger =  noteType.compareTo(((AccountNotesWrapper)objToCompare).noteType);
        }else{
            if(createdDate > ((AccountNotesWrapper)objToCompare).createdDate){
                returnInteger =  1;
            }else if(createdDate < ((AccountNotesWrapper)objToCompare).createdDate){
                returnInteger =  -1;
            }else{
                returnInteger =  0;
            }
        }
        if(sortType == 'DESC'){
            returnInteger *= -1;
        }
        return returnInteger;
    }
    
}