from odoo import models, fields


class Venda(models.Model):
    _inherit = "sale.order"

    approval_date = fields.Date(string="Data de Aprovação", readonly=True, requared=True, default= fields.Datetime.now)

