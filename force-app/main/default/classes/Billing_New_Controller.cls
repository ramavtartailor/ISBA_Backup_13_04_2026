/*-********************************************************************************************************
* Name         : Billing_New_Controller
* @Author      : Vikram Singh(singh.v@head-in-cloud.com)
* @Date        : 07-Feb-2017
* @Description : This apex class does  
* UPDATES
* Version          Developer                    Date                        Description
*-------------------------------------------------------------------------------------------
*     1.0            vikram                       07-Feb-2017                   Initial Creation 
****************************************************************************************************************/

public class Billing_New_Controller{
    
    public list<BillingLineWrapper> BillingLineWrapperList {get; set;}
    public AcctSeed__Billing__c billing {get; set;}
    public Account account {get; set;}
    public string accountId {get; set;}
    public string indexOfLineItemToBeRemoved {get; set;}
    public string billId {get; set;}
    public Billing_New_Controller(ApexPages.StandardController con){
        billId = con.getRecord().Id;
        system.debug('---billid is '+billId);
        billing = (AcctSeed__Billing__c)con.getRecord();
        BillingLineWrapperList = new list<BillingLineWrapper>();
        BillingLineWrapperList.add(new BillingLineWrapper(new AcctSeed__Billing_Line__c()));
    }
    
    
    public void onAccountSelect(){
        Account = new Account();
        Account = [SELECT id, BillingStreet, BillingState, BillingCity, BillingPostalCode, BillingCountry, shippingStreet, shippingState,
                    shippingCountry,AcctSeed__Billing_Contact__c, shippingPostalCode, shippingCity from Account where ID =:accountId];
                    
        Billing.AcctSeed__Billing_Street__c = account.billingstreet;
        Billing.AcctSeed__Billing_State__c = account.billingstate;
        Billing.AcctSeed__Billing_City__c = account.billingCity;
        Billing.AcctSeed__Billing_PostalCode__c = account.billingPostalCode;
        Billing.AcctSeed__Billing_Country__c = account.BillingCountry;
        
        Billing.AcctSeed__Billing_Contact__c = account.AcctSeed__Billing_Contact__c;
        Billing.AcctSeed__Shipping_Street__c = account.shippingStreet;
        Billing.AcctSeed__Shipping_City__c = account.shippingCity;
        Billing.AcctSeed__Shipping_State__c = account.shippingState;
        Billing.AcctSeed__Shipping_PostalCode__c = account.shippingPostalCode;
        Billing.AcctSeed__Shipping_Country__c = account.shippingCountry;
        
        system.debug('----Billing.AcctSeed__Billing_PostalCode__c--'+Billing.AcctSeed__Billing_PostalCode__c);
    }
    public PageReference Cancel()
    {
        PageReference page = new PageReference('/a1f/o');
        //PageReference page = new ApexPages.StandardController(Billing).view()
        page.setRedirect(true);
        return page;
    }
    
    public void addNewLine(){
        system.debug('---inside new row');
        BillingLineWrapperList.add(new BillingLineWrapper(new AcctSeed__Billing_Line__c()));
    }
    public void removeRow(){
        system.debug('---inside new row');
        if(indexOfLineItemToBeRemoved != null){
            BillingLineWrapperList.remove(integer.valueOf(indexOfLineItemToBeRemoved));
            //calculateAmount();
        }
        
    }
    //For inserting billing and line items
    public pagereference CreateBilling(){
        try{
            insert Billing;
            list<AcctSeed__Billing_Line__c> lineItemListToInsert = new list<AcctSeed__Billing_Line__c>();
            for(BillingLineWrapper wrap : BillingLineWrapperList){
                AcctSeed__Billing_Line__c li = new AcctSeed__Billing_Line__c();
                if(wrap.BillingLine != null){
                    li = wrap.BillingLine;
                    li.AcctSeed__Billing__c = Billing.Id;
                    lineItemListToInsert.add(li);
                }
            }
            insert lineItemListToInsert;
            return new ApexPages.StandardController(Billing).view();
        }catch(Exception e){
            return null;
        }
    }
    
    //--------Wrapper class for displaying list of billing line items
    public class BillingLineWrapper{
        public AcctSeed__Billing_Line__c BillingLine {get; set;}
        public BillingLineWrapper(AcctSeed__Billing_Line__c BillingLine){
            this.BillingLine = BillingLine;
            this.BillingLine.AcctSeed__Hours_Units__c = 1;
            this.BillingLine.AcctSeed__Rate__c = 0;
        }
        
    }
}