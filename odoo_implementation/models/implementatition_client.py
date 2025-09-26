from email.policy import default
from pkg_resources import require

from odoo import models, fields

class Client(models.Model):
    _name = "odoo.implementation.client"
    _description = "Cliente de Implementação Odoo"

    name = fields.Char(string="Nome", required=True)
    tel = fields.Char(string="Telefone")
    email = fields.Char(string="Email")
    nif = fields.Char(string="NIF")
    code = fields.Integer(string="Código", required=True, copy=False)


    _sql_constraints = [
        ("unique_code", "unique(code)", "O código do cliente deve ser único."),
    ]


