public class ProjectTaskTriggerHandler implements ITriggerHandler {

    private static final String ASSIGNEE_IS_CHANGED_TEMPLATE_NAME = 'Email_to_the_Task_Assignee';
    private static final String STATUS_IS_CHANGED_TEMPLATE_NAME = 'Email_to_the_Task_Reporter';
    private static final EmailTemplate TEMPLATE;

    private EmailTemplate setValuesTemplate(EmailTemplate template, String templateName) {
        template = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :templateName];
        return template;
    }

    private List<String> setAddress(Project_Task__c projectTask) {
        List<String> emails = new List<String>();
        List<User> contactList = [SELECT Id, Email FROM User WHERE Name = :projectTask.CreatedById];
        if (!contactList.isEmpty()) {
            for (User contact : contactList) {
                emails.add(contact.Email);
            }
        }
        return emails;
    }

    public void beforeInsert(List<SObject> newList) {
    }

    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
    }

    public void beforeDelete(Map<Id, SObject> oldMap) {
    }

    public void afterInsert(Map<Id, SObject> newMap) {
        taskName((Map<Id, Project_Task__c>) newMap);
    }

    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        sendEmails((Map<Id, Project_Task__c>) newMap, (Map<Id, Project_Task__c>) oldMap);
    }

    private void sendEmails(Map<Id, Project_Task__c> newMap, Map<Id, Project_Task__c> oldMap) {
        List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
        for (Project_Task__c newTask : newMap.values()) {

            Boolean isStatusChanged = newTask.Status__c != oldMap.get(newTask.Id).Status__c;
            Boolean isAssigneeChanged = newTask.Assignee__c != oldMap.get(newTask.Id).Assignee__c;

            if (isStatusChanged) {
                emailsList.add(prepareEmailMessageToReporter(newTask, TEMPLATE));
            }

            if (isAssigneeChanged) {
                emailsList.add(prepareEmailMessageToAssignee(newTask, TEMPLATE));
            }
        }

        if (!emailsList.isEmpty()) {
            Messaging.sendEmail(emailsList);
        }
    }

    private Messaging.SingleEmailMessage prepareEmailMessageToAssignee(Project_Task__c projectTask, EmailTemplate emailTemplate) {
        Messaging.SingleEmailMessage newEmailMessage = Messaging.renderStoredEmailTemplate(setValuesTemplate(emailTemplate, ASSIGNEE_IS_CHANGED_TEMPLATE_NAME).Id, projectTask.CreatedById, projectTask.Id);
        newEmailMessage.setToAddresses(setAddress(projectTask));
        newEmailMessage.setSaveAsActivity(false);
        return newEmailMessage;
    }

    private Messaging.SingleEmailMessage prepareEmailMessageToReporter(Project_Task__c projectTask, EmailTemplate emailTemplate) {
        Messaging.SingleEmailMessage newEmailMessage = Messaging.renderStoredEmailTemplate(setValuesTemplate(emailTemplate, STATUS_IS_CHANGED_TEMPLATE_NAME).Id, projectTask.CreatedById, projectTask.Id);
        newEmailMessage.setToAddresses(setAddress(projectTask));
        newEmailMessage.setSaveAsActivity(false);
        return newEmailMessage;
    }

    public void taskName(Map<Id, Project_Task__c> newMap) {
        for (Project_Task__c projectTask_i : newMap.values()) {
            sendRequestToBot(projectTask_i.Name);

        }
    }

    @Future(Callout= true)
    public static void sendRequestToBot(String taskName) {
        TelegrammCalloutService service = new TelegrammCalloutService();
        service.setMessageBody('604844518', 'New task is assigned to you: ' + taskName);
        service.setHeaders(null);
        service.sendMessage();
    }

    public void afterDelete(Map<Id, SObject> oldMap) {
    }
    public void afterUndelete(Map<Id, SObject> oldMap) {
    }

}