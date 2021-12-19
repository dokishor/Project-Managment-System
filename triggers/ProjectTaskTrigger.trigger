trigger ProjectTaskTrigger on Project_Task__c (before insert, after insert, before update, after update, before delete) {
    TriggerFactory.getInstance().handle(Project_Task__c.sObjectType);
}

