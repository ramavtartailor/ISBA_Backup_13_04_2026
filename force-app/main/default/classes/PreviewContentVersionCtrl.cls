public without sharing class PreviewContentVersionCtrl {

    public String versionData{get;set;}
    public String fileName{get;set;}

    public PreviewContentVersionCtrl() {        
        String recId = Apexpages.currentpage().getparameters().get('id'); 
        
        String query = 'SELECT Id, Title, VersionData FROM ContentVersion WHERE Id= \''+recId+'\' LIMIT 1';
        String resp = '';
        if(!test.isRunningTest()){
            resp = PaymentGatewayClass.QueryData(query);
        }
        else{
            resp = '{"Title":"t","VersionData":"test"}';
        }
        system.debug('resp--->'+resp);
        Map<String,Object> cvMap = (Map<String,Object>)Json.deserializeUntyped(resp);
        system.debug('cvMap--->'+cvMap);

        fileName = String.valueOf(cvMap.get('Title'));
        versionData = String.valueOf(cvMap.get('VersionData'));
        system.debug(versionData);
    }
}