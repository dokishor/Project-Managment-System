public class ProjectTaskTriggerHandler implements ITriggerHandler {

    private static final String ASSIGNEE_IS_CHANGED_TEMPLATE_NAME = 'Task_assignee_is_changed';
    private static final String STATUS_IS_CHANGED_TEMPLATE_NAME = 'Task_status_is_changed';

    private Map<String, Id> emailTemplateNameToId;

    public void beforeInsert(List<SObject> newList) {
    }

    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
    }

    public void beforeDelete(Map<Id, SObject> oldMap) {
    }


    public void afterInsert(Map<Id, SObject> newMap) {
        TelegramCalloutService service = new TelegramCalloutService();
        service.setHeaders(null);
        service.getMe();
        service.sendMessage();
    }

    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        //send emails to the task owner and task assignee if appropriate field is changed
        sendEmails((Map<Id, Project_Task__c>) newMap, (Map<Id, Project_Task__c>) oldMap);
    }

    private void sendEmails(Map<Id, Project_Task__c> newMap, Map<Id, Project_Task__c> oldMap) {
        //init templates
        initEmailTemplates();
        List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
        for (Project_Task__c newTask : newMap.values()) {

            Boolean isStatusChanged = newTask.Status__c != oldMap.get(newTask.Id).Status__c; //TODO: check if status is changed

            Boolean isAssigneeChanged = newTask.Assignee__c != oldMap.get(newTask.Id).Assignee__c; //TODO: check if assignee is changed

            if (isStatusChanged) {
                //Prepare email message using the Messaging.SingleEmailMessage class
                emailsList.add(prepareEmailMessage(newTask, emailTemplateNameToId.get(STATUS_IS_CHANGED_TEMPLATE_NAME)));
            }

            if (isAssigneeChanged) {
                //Prepare email message using the Messaging.SingleEmailMessage class
                emailsList.add(prepareEmailMessage(newTask, emailTemplateNameToId.get(ASSIGNEE_IS_CHANGED_TEMPLATE_NAME)));
            }
        }

        if (!emailsList.isEmpty()) {
            Messaging.sendEmail(emailsList);    //TODO: if emailsList is not empty, send emails using the Messaging.sendEmail() method.
        }
    }

    private void initEmailTemplates() {
        List<EmailTemplate> templates = [
                SELECT Id, DeveloperName
                FROM EmailTemplate
                WHERE DeveloperName = 'STATUS_IS_CHANGED_TEMPLATE_NAME'
                OR DeveloperName = 'ASSIGNEE_IS_CHANGED_TEMPLATE_NAME'
        ];

        this.emailTemplateNameToId = new Map<String, Id>();
        for (EmailTemplate template : templates) {
            emailTemplateNameToId.put(template.DeveloperName, template.Id);
        }
    }

    private Messaging.SingleEmailMessage prepareEmailMessage(Project_Task__c projectTask, Id emailTemplate) {
        Messaging.SingleEmailMessage newEmailMessage = new Messaging.SingleEmailMessage();
        newEmailMessage.setTemplateId(emailTemplate);
        newEmailMessage.setTargetObjectId(projectTask.CreatedById);
        newEmailMessage.setWhatId(projectTask.Id);
        newEmailMessage.setSaveAsActivity(false);
        return newEmailMessage;

    }

    public void afterDelete(Map<Id, SObject> oldMap) {
    }

    public void afterUndelete(Map<Id, SObject> oldMap) {
    }

}
