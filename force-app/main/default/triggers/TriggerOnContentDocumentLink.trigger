trigger TriggerOnContentDocumentLink on ContentDocumentLink (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        ContentDocumentLinkTriggerHandler.onAfterInsert(Trigger.new,Trigger.newMap);
        System.debug('test');
    }
}