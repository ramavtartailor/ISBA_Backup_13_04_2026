public class ConverttoApplicationLtng {
	@AuraEnabled
    public static String  getProfileName(){
        List<User> usrList = [SELECT Id, Profile.Name FROM User WHERE ProfileId=: UserInfo.getProfileId()]; 
        String userName = usrList[0].Profile.Name;        
        return userName;
    }
    
    @AuraEnabled
    public static String  getCongaMsg(Id policyId){
        String msg = PolicyDocumentsUtility.policyToApplicationAccountingTransactions(policyId);   
        return msg;
    }
}