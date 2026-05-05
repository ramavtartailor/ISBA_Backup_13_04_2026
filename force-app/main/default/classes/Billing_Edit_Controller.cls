/*-********************************************************************************************************
* Name         : Billing_Edit_Controller
* @Author      : Vikram Singh(singh.v@head-in-cloud.com)
* @Date        : 21-Feb-2017
* @Description : This apex class does  
* UPDATES
* Version          Developer                    Date                        Description
*-------------------------------------------------------------------------------------------
*     1.0            vikram                       21-Feb-2017                   Initial Creation 
****************************************************************************************************************/

public with sharing class Billing_Edit_Controller{
    
public list<BillingLineWrapper> BillingLineWrapperList {get; set;}
    public AcctSeed__Billing__c billing {get; set;}
    public Account account {get; set;}
    public string accountId {get; set;}
    public string indexOfLineItemToBeRemoved {get; set;}
    public string billId {get; set;}
    public list<AcctSeed__Billing_Line__c> billingLineListToDelete {get; set;}
    public Billing_Edit_Controller(ApexPages.StandardController con){
        billId = con.getRecord().Id;
        billingLineListToDelete = new list<AcctSeed__Billing_Line__c>();
        BillingLineWrapperList = new list<BillingLineWrapper>();
        system.debug('---billid is '+billId);
        billing = (AcctSeed__Billing__c)con.getRecord();
        billing = [select AcctSeed__Customer__c,AcctSeed__Accounting_Period__c,AcctSeed__Billing_Street__c, AcctSeed__Billing_State__c,AcctSeed__Billing_City__c,AcctSeed__Billing_PostalCode__c,
                 AcctSeed__Billing_Country__c, id, AcctSeed__Shipping_Street__c,AcctSeed__Shipping_City__c,AcctSeed__Shipping_State__c,
                 AcctSeed__Shipping_Country__c, AcctSeed__Shipping_PostalCode__c, AcctSeed__Date__c, AcctSeed__Billing_Terms_Name__c, 
                 AcctSeed__Due_Date2__c,Billing_Zip_Code__c , (select id, AcctSeed__Billing__c,AcctSeed__Comment__c, AcctSeed__Hours_Units__c, AcctSeed__Rate__c, 
                 AcctSeed__Revenue_GL_Account__c from AcctSeed__Project_Billing_Lines__r),AcctSeed__Billing_Contact__c from AcctSeed__Billing__c where id=:billId];
                 
        for(AcctSeed__Billing_Line__c li : billing.AcctSeed__Project_Billing_Lines__r){
            BillingLineWrapperList.add(new BillingLineWrapper(li));
        }        
        
    }
    
    
    public void onAccountSelect(){
        Account = new Account();
        Account = [SELECT id, BillingStreet, BillingState, BillingCity, BillingPostalCode, BillingCountry, shippingStreet, shippingState,
                    shippingCountry, shippingPostalCode, shippingCity,AcctSeed__Billing_Contact__c from Account where ID =:accountId];
                    
        Billing.AcctSeed__Billing_Street__c = account.billingstreet;
        Billing.AcctSeed__Billing_State__c = account.billingstate;
        Billing.AcctSeed__Billing_City__c = account.billingCity;
        Billing.AcctSeed__Billing_PostalCode__c = account.billingPostalCode;
        Billing.AcctSeed__Billing_Country__c = account.BillingCountry;
        Billing.AcctSeed__Billing_Contact__c = account.AcctSeed__Billing_Contact__c;
        /*Billing.AcctSeed__Shipping_Street__c = account.shippingStreet;
        Billing.AcctSeed__Shipping_City__c = account.shippingCity;
        Billing.AcctSeed__Shipping_State__c = account.shippingState;
        Billing.AcctSeed__Shipping_PostalCode__c = account.shippingPostalCode;
        Billing.AcctSeed__Shipping_Country__c = account.shippingCountry;*/
        
        system.debug('----Billing.AcctSeed__Billing_PostalCode__c--'+Billing.AcctSeed__Billing_PostalCode__c);
    }
    
    public void addNewLine(){
        system.debug('---inside new row');
        BillingLineWrapperList.add(new BillingLineWrapper(new AcctSeed__Billing_Line__c()));
        
    }
    public void removeRow(){
        system.debug('---inside new row');
        if(indexOfLineItemToBeRemoved != null){
            if(BillingLineWrapperList.get(integer.valueOf(indexOfLineItemToBeRemoved)).BillingLine.Id != null){
                billingLineListToDelete.add(BillingLineWrapperList.get(integer.valueOf(indexOfLineItemToBeRemoved)).BillingLine);
            }
            
            BillingLineWrapperList.remove(integer.valueOf(indexOfLineItemToBeRemoved));
            //calculateAmount();
        }
        
    }
    //For inserting billing and line items
    public pagereference CreateBilling(){
        try{
            update Billing;
            list<AcctSeed__Billing_Line__c> lineItemListToInsert = new list<AcctSeed__Billing_Line__c>();
            for(BillingLineWrapper wrap : BillingLineWrapperList){
                AcctSeed__Billing_Line__c li = new AcctSeed__Billing_Line__c();
                if(wrap.BillingLine != null){
                    li = wrap.BillingLine;
                    li.AcctSeed__Billing__c = Billing.Id;
                    lineItemListToInsert.add(li);
                }
            }
            upsert lineItemListToInsert;
            if(billingLineListToDelete != null && !billingLineListToDelete.isEmpty()){
                delete billingLineListToDelete;
            }
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
            if(this.BillingLine.AcctSeed__Rate__c == null)
                this.BillingLine.AcctSeed__Rate__c = 0;
        }
        
    }
}