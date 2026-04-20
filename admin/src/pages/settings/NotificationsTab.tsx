import React, { useEffect, useState } from 'react';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { SaveBanner } from '@/components/shared/SaveBanner';
import { useNotificationTemplates, useUpdateTemplate } from '@/hooks/useSystem';

interface NotifTemplate {
  event: string;
  channel: string;
  subject: string;
  body: string;
}

export function NotificationsTab() {
  const templatesQuery = useNotificationTemplates();
  const updateTemplate = useUpdateTemplate();
  const [templates, setTemplates] = useState<NotifTemplate[]>([]);
  const [saved, setSaved] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    const raw = templatesQuery.data as unknown as Array<Partial<NotifTemplate>> | undefined;
    if (!raw) return;
    setTemplates(raw.map(t => ({
      event: t.event ?? '',
      channel: t.channel ?? 'push',
      subject: t.subject ?? '',
      body: t.body ?? '',
    })));
  }, [templatesQuery.data]);

  const onChange = (idx: number, field: keyof NotifTemplate, value: string) => {
    setTemplates(prev => prev.map((t, i) => i === idx ? { ...t, [field]: value } : t));
    setErrors(prev => ({ ...prev, [idx]: '' }));
  };

  const onSave = async () => {
    const errs: Record<string, string> = {};
    templates.forEach((t, i) => {
      if (!t.body.trim()) errs[String(i)] = 'Template body cannot be empty.';
    });
    if (Object.keys(errs).length > 0) { setErrors(errs); return; }
    setErrors({});
    await Promise.all(
      templates.map(t => updateTemplate.mutateAsync({ event: t.event, body: t.body }).catch(() => {})),
    );
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-medium">Notification Templates</h3>
        <SaveBanner visible={saved} />
      </div>

      {templatesQuery.isPending ? (
        <p className="text-sm text-text-muted text-center py-6">Loading templates...</p>
      ) : templates.length === 0 ? (
        <p className="text-sm text-text-muted text-center py-6">No templates configured.</p>
      ) : (
        <div className="space-y-6 max-w-2xl">
          {templates.map((tpl, idx) => (
            <div key={tpl.event} className="space-y-3 p-4 bg-surface-hover border border-border rounded-lg">
              <div className="flex items-center justify-between">
                <p className="text-sm font-medium text-text-main capitalize">{tpl.event.replace(/_/g, ' ')}</p>
                <Badge variant="default">{tpl.channel}</Badge>
              </div>
              {tpl.subject !== undefined && (
                <div className="space-y-1">
                  <label className="text-xs font-medium text-text-muted">Subject</label>
                  <Input
                    value={tpl.subject}
                    onChange={(e) => onChange(idx, 'subject', e.target.value)}
                  />
                </div>
              )}
              <div className="space-y-1">
                <label className="text-xs font-medium text-text-muted">Body</label>
                <Input
                  value={tpl.body}
                  onChange={(e) => onChange(idx, 'body', e.target.value)}
                  className={errors[String(idx)] ? 'border-danger' : ''}
                />
                {errors[String(idx)] && <p className="text-xs text-danger">{errors[String(idx)]}</p>}
              </div>
            </div>
          ))}
          <Button onClick={onSave}>Save Templates</Button>
        </div>
      )}
    </div>
  );
}
