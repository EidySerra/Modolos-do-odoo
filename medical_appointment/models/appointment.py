from email.policy import default

from odoo import models, fields

class appointment(models.Model):
    _name = 'medical.appointment'
    _description = 'appointment'
    _rec_name = 'patient_id'

    patient_id = fields.Many2one('medical.patient', string = 'Paciente', required=True)
    doctor_id = fields.Many2one('medical.doctor', string='Doctor', required=True)
    appointment_date = fields.Date(string='Data da consulta', required=True)
    description = fields.Text(string='Descrição da Consulta', required=True)
    state = fields.Selection(
        [
            ('draft', 'Rascunho'),
            ('confirmed', 'Corfimado'),
            ('done,', 'Concluido'),
            ('cancelled', 'Cancelado'),
        ], string='Estado da consulta', default='draft')

