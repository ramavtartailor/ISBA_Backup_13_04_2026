public class CustomerPortalLinkCtrl {
	@auraEnabled
    public static String getLink(String recId){
        Account acc = new Account();
        acc.Id = recId;
        acc.Payment_Link_Activation_Started_at__c = system.now();
        update acc;
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        
        String baseUrl = runningInASandbox ? 'https://sb-portal.isbamutual.com/' : 'https://portal.isbamutual.com/';
        baseUrl += '?id='+EncodingUtil.urlEncode(PaymentGateway_Ctrl.processEncryption(recId, Label.Encryption_Key_Payment_Id),'UTF-8');
        System.debug('URL => '+ baseUrl);            
        return baseUrl;
    }
}