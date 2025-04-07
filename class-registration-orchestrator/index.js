const df = require('durable-functions');
const { OrchestrationError } = require('../shared/errors');

const orchestrator = df.orchestrator(function* (context) {
    context.log('[orchestrator] Starting with input:', context.bindingData.input);
    
    // Create a result object to track progress and store results
    const result = {
        status: 'started',
        error: null,
        data: {
            folderId: null,
            gradebookId: null,
            classId: null
        }
    };

    try {
        const bindingInput = context.bindingData.input;
        
        // Validate all inputs upfront
        const requiredFields = ['teacher_name', 'gradebook_name', 'email', 'class_id'];
        const missingFields = requiredFields.filter(field => !bindingInput?.[field]);
        
        if (missingFields.length > 0) {
            throw new OrchestrationError(
                'INVALID_INPUT',
                `Missing required fields: ${missingFields.join(', ')}`,
                { providedInput: bindingInput }
            );
        }

        const { teacher_name, gradebook_name, email, class_id, folder_id } = bindingInput;

        const newTeacher = !folder_id;

        // Step 1: Create folder
        if (newTeacher) {
            try {
                context.log('[orchestrator] Creating folder...');
                const folderResult = yield context.df.callActivity('create-folder', { name: teacher_name });
                result.data.folderId = folderResult.id;
                context.log('[orchestrator] Folder created:', folderResult.id);
            } catch (error) {
                throw new OrchestrationError('CREATE_FOLDER_FAILED', error.message, error);
            }
        }

        // Step 2: Initiate copy operation
        try {
            context.log('[orchestrator] Initiating copy operation...');
            const copyResult = yield context.df.callActivity('copy-drive-item', {
                name: gradebook_name,
                parentReference: {
                    id: result.data.folderId || folder_id
                }
            });
            context.log('[orchestrator] Copy operation initiated:', copyResult.monitoringUrl);

            // Send message to Service Bus queue for monitoring
            context.bindings.monitorCopyStatus = {
                monitoringUrl: copyResult.monitoringUrl,
                timestamp: new Date().toISOString(),
                classId: class_id,
                folderId: result.data.folderId
            };
            context.log('[orchestrator] Monitoring message sent to Service Bus');
        } catch (error) {
            throw new OrchestrationError('COPY_INITIATION_FAILED', error.message, error);
        }

        // Step 3: Queue teacher invite
        if (newTeacher) {
            try {
                context.log('[orchestrator] Queueing teacher invite...');
                context.bindings.inviteTeacher = {
                folderId: result.data.folderId || folder_id,
                email
            };
            context.log('[orchestrator] Teacher invite queued');
            } catch (error) {
                throw new OrchestrationError('QUEUE_INVITE_FAILED', error.message, error);
            }
        }

        result.status = 'completed';
        return result;

    } catch (error) {
        result.status = 'failed';
        result.error = {
            code: error.code || 'UNKNOWN_ERROR',
            message: error.message,
            details: error.details || null,
            timestamp: new Date().toISOString()
        };
        
        context.log.error('[orchestrator] Failed:', result.error);
        return result;
    }
});

module.exports = orchestrator;
