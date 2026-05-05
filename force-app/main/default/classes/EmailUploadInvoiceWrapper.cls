public class EmailUploadInvoiceWrapper{
    public String policyID { get; set; }
    public String invoiceID { get; set; }
    public String invoiceType { get; set; }
    public String invoiceAmount { get; set; }
    public String firmName{get;set;}
    public String zipCode { get; set; }
    public String issueDate { get; set; }
    public String firmId{get;set;}
    public String effectiveDate{ get; set; }
    public String billingStreet { get; set; }
    public String billingCity { get; set; }
    public String billingState{get;set;}
    public String billingZip{ get; set; }
    
    public EmailUploadInvoiceWrapper(String policyID,String invoiceID,String invoiceType,String invoiceAmount,String firmName,String zipCode,String issueDate,String firmId,String effectiveDate,String billingStreet,String billingCity,String billingState,String billingZip){
        
        this.policyID=policyID;
        this.invoiceID=invoiceID;
        this.invoiceType=invoiceType;
        this.invoiceAmount=invoiceAmount;
        this.firmName=firmName;
        this.zipCode=zipCode;
        this.issueDate=issueDate;
        this.firmId=firmId;
        this.effectiveDate=effectiveDate;
        this.billingStreet = billingStreet;
        this.billingCity = billingCity;
        this.billingState = billingState;
        this.billingZip = billingZip;
    }
}