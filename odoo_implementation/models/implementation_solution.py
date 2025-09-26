from email.policy import default
from dataclasses import field


from odoo import models, fields

class Solution(models.Model):
    _name = "odoo.implementation.solution"
    _description = "Solução de Implementação Odoo"

    name = fields.Char(string='Nome', required=True)
    tipo = fields.Char(string='Tipo')
    category = fields.Selection([
        ('saude', 'Saúde'),
        ('educacao', 'Educação'),
        ('outros', 'Outros')
    ], string="Categoria")

