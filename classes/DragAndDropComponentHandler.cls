public with sharing class DragAndDropComponentHandler {
    @AuraEnabled
    public static List<Project_Task__c> getAllTask(Id recordId){
        System.debug(recordId);
        return [SELECT Id, Name, Status__c FROM Project_Task__c WHERE Project__c=:recordId];
    }

    @AuraEnabled
    public static void updateTask(Id newTaskId, String newStatus){
        Project_Task__c updateTask = new Project_Task__c(Id = newTaskId, Status__c = newStatus);
        Database.update(updateTask);
    }

    @AuraEnabled
    public static void deleteTask(Id newTaskId){
        Project_Task__c deleteTask = new Project_Task__c(Id = newTaskId);
        Database.delete(deleteTask);
    }
}