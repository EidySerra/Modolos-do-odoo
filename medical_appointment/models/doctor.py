from email.policy import default

from pkg_resources import require

from odoo import models, fields


class doctor(models.Model):
    _name = "medical.doctor"
    _description = "doctor"

    name = fields.Char('Nome do Médico', required=True)
    speciality = fields.Char(string='Especialidade Medica', required=True)
    phone = fields.Char(string='Telefone', required=True)
    email = fields.Char(string='Email')
    active = fields.Boolean(string='Estado', default=True)

    appointment_ids = fields.One2many(
        'medical.appointment',  # modelo alvo
        'doctor_id',  # campo Many2one que faz a ligação
        string="Consultas"
    )



