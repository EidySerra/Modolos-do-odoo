from odoo import models, fields

class Supplier(models.Model):
    _name = "pharma.supplier"
    _description = "Fornecedor"

    name = fields.Char(string="Nome do fornacedor")
    nif = fields.Char(string="Nif")
    phone = fields.Char(string="Telefone")
    email = fields.Char(string="Email")
    address = fields.Text(string="Endereço")
