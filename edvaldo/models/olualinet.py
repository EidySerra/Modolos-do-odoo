from email.policy import default

from odoo import models, fields


class Olualinet(models.Model):
    _name = "olualinet.training" # nome do objecto(equivalente a olualinet_training na base de dados postgras
    _description = "Treinamento na Olualinet"


    name = fields.Char("Name")
    category = fields.Char(string="Category")
    telephone = fields.Integer(string="Telephone")
    price = fields.Float(string="Price")
    estado = fields.Boolean(string="Estado", default="tru")
    genero = fields.Selection([("male", "Masculino"), ("female", "Femenino"), ("others", "Outros")], string="Genero", default="male")
    date = fields.Date(string="Data de nascimento")




    # O nosso beckend