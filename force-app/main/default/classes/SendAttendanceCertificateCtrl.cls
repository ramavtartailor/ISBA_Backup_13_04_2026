public class SendAttendanceCertificateCtrl {
    @AuraEnabled
    public static string callBatch(String recId){
        if(String.isNotBlank(recId)){
            SendAttendanceCertificateBatch b = new SendAttendanceCertificateBatch(recId);
            string batchInstanceId = database.ExecuteBatch(b,50);
            return batchInstanceId;
        }
        return null;
    }
}