from odoo import models, fields


class Venda(models.Model):
    _inherit = "sale.order"

    marca = fields.Char(string="Modelo/Marca do carro")
    matricula = fields.Char(string="Matricula do carro")
    color = fields.Char(string="Cor do carro")
    km = fields.Float(string="Kilometragem")
    chassi = fields.Integer(string="Numero do chassi")


    movimentacoes_ids = fields.One2many(
    "car.enter.out", "car_id", string="Movimentações"
)
