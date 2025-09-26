

from odoo import models, fields


class patient(models.Model):
    _name = "medical.patient"
    _description = "patient"

    name = fields.Char('Nome', required=True)
    birth_day = fields.Date(string="Data de Nascimento", Required=True)
    gander = fields.Selection([
        ('male', 'Masculino'),
        ('female', 'Femenino'),
        ('others', 'Outros'),
    ], string="Genero")
    phone = fields.Char(string="Telefone", required=True)
    email = fields.Char(string="Email", required=True)
    address = fields.Text(string="Endereço", Required=True)

    appointment_ids = fields.One2many(
        'medical.appointment',  # modelo das consultas
        'patient_id',  # campo Many2one que liga ao paciente
        string="Consultas"
    )


