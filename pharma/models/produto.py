from tokenize import String

from odoo import models, fields

class Product(models.Model):
    _name = "pharma.product"
    _description = "produto"

    name = fields.Char(String="Nome do produto")
    qty = fields.Integer(String="Quantidade")
    price = fields.Float(String="Preço")
    date_fb = fields.Date(String="Data de expiracão")
    date_exp = fields.Date(String="Data de fabrico")
    id_supplier = fields.Many2one('pharma.supplier', string="Nome fornecedor")