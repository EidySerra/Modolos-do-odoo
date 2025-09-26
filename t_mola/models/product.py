from odoo import models, fields

class ProductTemplate(models.Model):
    _inherit = "product.template"

    volume = fields.Float("Volume")
    codsup = fields.Char("CODSUP")
    formato = fields.Char("Formato")