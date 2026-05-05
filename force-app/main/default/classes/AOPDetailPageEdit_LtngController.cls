/*
Name : AOPDetailPageEdit_LtngController
Auther : 
Date : 26 April 2017
Description : this lightning page of clone account detail page
*/
global class AOPDetailPageEdit_LtngController{ 
    
    //Insrance Variables
    global Policy__c appPolicy{get;set;}
    global boolean isSaErp{get;set;}  
    global List<Policy_AOP__c> aops{get;set;}
    global String error{get;set;}
    global String success{get;set;}
    global Integer rowIdx{get;set;}
    public Map<id,Decimal> aopPercentage{get;set;}
    global list<wrappercls> wrapperObjlist{get;set;}
    
    global List<id> removeAopPols ;
    public Map<Id,Decimal> aopMod = new Map<Id,Decimal>();
    global List<AOP_Factor__c> lstOfAopFactors{get;set;}
    global List<Policy_AOP__c> lstOfPolices;
    global String appId;
    
    global class wrappercls{
        global id factorId{get;set;}
        global string name{get;set;}
        global decimal percentage{get;set;}
        global decimal mod{get;set;}
        
    }
        
    //Constructor
    global AOPDetailPageEdit_LtngController(){
        removeAopPols =new List<Id>();
        isSaErp = false;
        wrapperObjlist= new list<wrappercls>();
        lstOfAopFactors = new List<AOP_Factor__c>();
        //lstOfAopFactors=[select id,Name,AOP_Mod__c from  AOP_Factor__c where Master_Factor__r.Default__c = true order by name Limit 1000];
        appId = ApexPages.currentPage().getParameters().get('Id');
        
        Map<String,Policy_AOP__c> oldAopMap = new Map<String,Policy_AOP__c>();
        if(ApexPages.currentPage().getParameters().get('policy') != null){
            isSaErp = true;
            String policyId = ApexPages.currentPage().getParameters().get('policy');
            List<Policy_AOP__c> policyAopList = [SELECT Id, Policy__c, AOP__c,Percentage__c FROM Policy_AOP__c WHERE Policy__c=: policyId];
            
            for(Policy_AOP__c aop: policyAopList){
                oldAopMap.put(aop.AOP__c, aop);
            }
        }
        aopPercentage = new Map<id,Decimal>();
        aops = new List<Policy_AOP__c>(); 
        
        
        if( String.isNotBlank( appId ) && appId.length() > 14 ){
            
            lstOfPolices = new List<Policy_AOP__c>();
            lstOfPolices = [select id,Name,AOP__c,Policy__c,AOP__r.Name,Factor_Mod__c,Percentage__c from Policy_AOP__c where Policy__c=:appId];
            
            for(Policy_AOP__c po:lstOfPolices){
                aops.add(po);
                aopPercentage.put(po.AOP__r.id, po.Percentage__c);
            }         
            
            List<Policy__c> appPolicies = [SELECT Id, Name,Account__r.Name,Effective_Date__c,Legacy_AOP_List__c,AOP_Master_Factor__c  FROM Policy__c WHERE Id =: appId LIMIT 1];
            if( appPolicies != null && appPolicies .size() > 0 ){
                appPolicy = appPolicies[0];
                if(aops.size()==0){
                    aops.add( new Policy_AOP__c( Policy__c = appPolicy.Id ) );
                }
                //lstOfAopFactors = [select id,Name,AOP_Mod__c from  AOP_Factor__c where From_Date__c <=: appPolicy.Effective_Date__c and  To_Date__c >=: appPolicy.Effective_Date__c order by name Limit 1000];
                lstOfAopFactors = [select id,Name,AOP_Mod__c from  AOP_Factor__c where Master_Factor__c =: appPolicy.AOP_Master_Factor__c order by name Limit 1000];
                system.debug(lstOfAopFactors);
                for (AOP_Factor__c factorObj: lstOfAopFactors){
                    wrappercls wrapperObj= new wrappercls();
                    wrapperObj.name = factorObj.Name;
                    wrapperObj.mod = factorObj.AOP_Mod__c;
                    wrapperObj.factorId = factorObj.id;
                    if(aopPercentage.containsKey(factorObj.id)){
                        wrapperObj.percentage = aopPercentage.get(factorObj.id);
                        
                    }
                    else if(oldAopMap.containsKey(factorObj.id)){
                        wrapperObj.percentage = oldAopMap.get(factorObj.id).Percentage__c;
                    }
                    else{
                        wrapperObj.percentage = 0;
                    }
                    wrapperObjlist.add(wrapperObj); 
                }
            }
        }
        else{
        }
        
        
    }
    //Add Row
    global void addRow(){
        error = '';
        success = '';
        if( appPolicy != null ){
            aops.add( new Policy_AOP__c( Policy__c = appPolicy.Id ) );
        }
    }
    
    //Save Record
    global PageReference saveAOP(){
        error ='';
        success = 'Record saved successfully. ';
        decimal percentageSum = 0;
        /*  for( Policy_AOP__c aop :  aops ){
if( aop.Percentage__c != null && aop.Percentage__c >= 0 ){
percentageSum += aop.Percentage__c;
}
}*/
        for( wrappercls wrapperObj:wrapperObjlist){
            if( wrapperObj.percentage != null && wrapperObj.percentage > 0 ){
                percentageSum += wrapperObj.percentage;
            }
        }
        if( percentageSum == 100 ){
            try{
                //if(removeAopPols.size()>0){
                // delete [select id from Policy_AOP__c where id in:removeAopPols];
                delete [select id from Policy_AOP__c where Policy__c=:appId];
                //}
                //upsert  aops;
                string legacy='';
                List<Policy_AOP__c> polObjList = new List<Policy_AOP__c>(); 
                for(wrappercls wrapperObj:wrapperObjlist){
                    if(wrapperObj.percentage>0){
                        Policy_AOP__c polObj = new Policy_AOP__c();
                        polObj.Policy__c = appId;
                        polObj.AOP__c = wrapperObj.factorId;
                        polObj.Factor_Mod__c = wrapperObj.mod;
                        polObj.Percentage__c = wrapperObj.percentage;
                        polObjList.add(polObj);
                        
                        //  legacy = legacy+'\n'+wrapperObj.name+' ('+wrapperObj.percentage+'%)';
                    }
                }
                TriggerFactory.isUpdatePremium = false;
                if(!polObjList.isempty()){
                    insert polObjList;
                }
                TriggerFactory.isUpdatePremium = true;
                // appPolicy.Legacy_AOP_List__c = legacy;
                update appPolicy;
                //return new PageReference( '/' + appPolicy.Id )
                return null;
                
            }catch(DMLException e){
                system.debug(' msg :: ' + e.getMessage());
                system.debug('line :: ' + e.getLineNumber());
                error = e.getdmlMessage(0);
                success = '';
                return null;
                
            }catch(Exception e){
                error = e.getMessage();
                success = '';
                return null;
            }
            
        }else{
            error = 'Error: Total percentage must be equal to hundred';
            success = '';
        }
        return null;
    }
    
    //Remove Row
    global void removeRow(){
        error = '';
        success = '';
        System.debug('rowIdx----'+rowIdx);
        System.debug('aopsSize----'+aops.size());
        if( rowIdx != null && aops.size() > 1 ){
            Policy_AOP__c objAop=aops[rowIdx];
            if(objAop.id!=null){
                removeAopPols.add(objAop.id); 
            }
            aops.remove( rowIdx );
        }
    }
    public void updateAOPModValue(){
        error = '';
        if( rowIdx > -1 && aops.size() > 0 ){
            if(String.IsNotBlank(aops[rowIdx].AOP__c) && aopMod.containsKey(aops[rowIdx].AOP__c)){
                aops[rowIdx].Factor_Mod__c = aopMod.get(aops[rowIdx].AOP__c);
            }
        }
    }
    @RemoteAction
    global static List<sObject> getLookupRecord(String likeString , String objectName) {
        if(String.IsNotBlank(likeString) && String.IsNotBlank(objectName)){
            likeString = '%'+likeString+'%';
            String query = '';
            
            query = 'SELECT Id, Name FROM '+objectName+' WHERE Name LIKE : likeString LIMIT 50';
            return database.query(query);
        }
        return null;
    }
    global List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        for(AOP_Factor__c Aop:lstOfAopFactors){
            aopMod.put(aop.id,Aop.AOP_Mod__c);
            options.add(new SelectOption(Aop.id,Aop.Name));
        }
        return options;
    }
    
}