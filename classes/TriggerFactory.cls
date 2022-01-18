public with sharing class TriggerFactory {

    private final static TriggerFactory INSTANCE = new TriggerFactory();
    private final Map<SObjectType, System.Type> HANDLERS;

    private TriggerFactory() {
        this.HANDLERS = new Map<SObjectType, System.Type>
        {
                Project_Task__c.SObjectType => ProjectTaskTriggerHandler.class
        };
    }

    public static TriggerFactory getInstance() {
        return TriggerFactory.INSTANCE;
    }

    public void handle(Schema.SObjectType objectType) {
        if(!this.HANDLERS.containsKey(objectType)){
            throw new TriggerException('No Trigger Handler registered for Object Type: ' + objectType);
        }
        ITriggerHandler handler = (ITriggerHandler)this.HANDLERS.get(objectType).newInstance();
        execute(handler);
    }

    private void execute(ITriggerHandler handler){
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                handler.beforeInsert(Trigger.new);
            }
            if(Trigger.isUpdate){
                handler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
            }
            if(Trigger.isDelete){
                handler.beforeDelete(Trigger.oldMap);
            }
        }
        else if(Trigger.isAfter){
            if(Trigger.isInsert){
                handler.afterInsert(Trigger.newMap);
            }
            if(Trigger.isUpdate){
                handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
            }
            if(Trigger.isDelete){
                handler.afterDelete(Trigger.oldMap);
            }
        }
    }

    public class TriggerException extends Exception{}
}