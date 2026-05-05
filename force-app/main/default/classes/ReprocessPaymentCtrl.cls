public class ReprocessPaymentCtrl {
    public Set<Id> billingIds;
    public Id billingId;
	public ReprocessPaymentCtrl(){
        billingIds = new Set<Id>();
        billingIds.add(apexpages.currentpage().getparameters().get('id'));
        billingId = apexpages.currentpage().getparameters().get('id');
    }
    public PageReference reprocessPayment(){
        Batch_PaymentGateway batch = new Batch_PaymentGateway(billingIds);
        Database.executeBatch(batch,1);
        return new PageReference('/'+billingId);
    }
}