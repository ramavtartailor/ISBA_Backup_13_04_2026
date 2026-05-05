public class PolicyClaimCounter{
    
    public static void createClaimIds(List<Policy_Claim__c> claimList){
        
        //String year = String.valueOf(System.today().year()).right(2);
        Map<String,ClaimAutoNumber__c> claimAutoNumMap = new Map<String,ClaimAutoNumber__c>();
        for(ClaimAutoNumber__c autoNum : [select id,Name,Counter__c from ClaimAutoNumber__c]){
            claimAutoNumMap.put(autoNum.Name,autoNum);
        }
        
                
        //ClaimAutoNumber__c autoNum = ClaimAutoNumber__c.getValues(year);

        //Integer counter = 0;
        //Integer count = 0;
        for(Policy_Claim__c claim: claimList){
            //if(String.isBlank(claim.Legacy_Claim_ID__c) || String.isBlank(claim.Claim_ID__c)){
            if(String.isBlank(claim.Claim_ID__c)){
                String year = String.valueOf(claim.Report_Date__c.year()).right(2);
                if(!claimAutoNumMap.containsKey(year)){
                    claimAutoNumMap.put(year,new ClaimAutoNumber__c(Name = year, Counter__c = 0));
                }
                ClaimAutoNumber__c autoNum = claimAutoNumMap.get(year);
                Decimal counter = Integer.valueOf(autoNum.Counter__c);
                counter++;
                autoNum.Counter__c = counter;
                claimAutoNumMap.put(year,autoNum);
                claim.Claim_Id__c = year + '-' + (autoNum.Counter__c <= 9 ? '00' + String.valueOf(autoNum.Counter__c) : autoNum.Counter__c <= 99 ? '0' + String.valueOf(autoNum.Counter__c): String.valueOf(autoNum.Counter__c));
                
                //claimAutoNumList.add(autoNum);
            }
            /*
            else{
                claim.Claim_ID__c = claim.Legacy_Claim_ID__c;                
            }
            */
        }
        
        /*if(!claimAutoNumList.isEmpty()){
            upsert claimAutoNumList;
        }*/
        System.debug(claimAutoNumMap);
        if(claimAutoNumMap.size()>0){
            upsert claimAutoNumMap.values();
        }
        
    }
    
}