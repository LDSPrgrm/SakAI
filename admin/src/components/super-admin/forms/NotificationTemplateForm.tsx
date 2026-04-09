// Notification template editor form — spec superadmin.md §2 forms
import React from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const schema = z.object({
  event: z.string().min(1, 'Event key is required'),
  body:  z.string().min(1, 'Template body is required'),
});
type NotificationTemplateFormValues = z.infer<typeof schema>;

interface NotificationTemplateFormProps {
  eventKey?:    string;
  defaultBody?: string;
  loading?: boolean;
  onSubmit: (event: string, body: string) => void;
  onCancel: () => void;
}

export function NotificationTemplateForm({ eventKey, defaultBody, loading, onSubmit, onCancel }: NotificationTemplateFormProps) {
  const { register, handleSubmit, formState: { errors } } = useForm<NotificationTemplateFormValues>({
    resolver: zodResolver(schema),
    defaultValues: { event: eventKey ?? '', body: defaultBody ?? '' },
  });

  return (
    <form onSubmit={handleSubmit(({ event, body }) => onSubmit(event, body))} className="flex flex-col gap-4">
      <div>
        <label className="text-xs font-medium text-text-muted block mb-1">Event Key</label>
        <input {...register('event')} readOnly={!!eventKey} placeholder="e.g. ride_completed" className={inputCls + (eventKey ? ' opacity-50' : '')} />
        {errors.event && <p className="text-xs text-danger mt-1">{errors.event.message}</p>}
      </div>
      <div>
        <label className="text-xs font-medium text-text-muted block mb-1">Template Body</label>
        <textarea {...register('body')} rows={5} placeholder="Your ride has been completed. Thank you!" className={inputCls + ' resize-none'} />
        <p className="text-xs text-text-muted mt-1">Available variables: {'{{rider_name}}'}, {'{{driver_name}}'}, {'{{amount}}'}, {'{{ride_id}}'}</p>
        {errors.body && <p className="text-xs text-danger mt-1">{errors.body.message}</p>}
      </div>
      <div className="flex justify-end gap-3">
        <button type="button" onClick={onCancel} className="px-4 py-2 text-sm rounded-lg border border-border text-text-muted hover:text-text-main transition-colors">Cancel</button>
        <button type="submit" disabled={loading} className="px-4 py-2 text-sm rounded-lg bg-primary hover:bg-primary/90 text-white font-medium transition-colors disabled:opacity-50">
          {loading ? 'Saving…' : 'Save Template'}
        </button>
      </div>
    </form>
  );
}

const inputCls = 'bg-background border border-border rounded-lg px-3 py-2 text-sm text-text-main w-full focus:outline-none focus:border-primary placeholder:text-text-muted';
