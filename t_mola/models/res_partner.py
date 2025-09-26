from email.policy import default
from odoo import models, fields, api

class ResPartner(models.Model):
    _inherit = "res.partner"

    client_number = fields.Char(
        string="Número do cliente",
        readonly=True,
        copy=False,
        index=True,   # ajuda nas pesquisas
        default="New"
    )

    @api.model
    def create(self, vals):
        if vals.get('client_number', 'New') == 'New':
            vals['client_number'] = self.env['ir.sequence'].next_by_code('res.partner.sequence') or 'New'
        return super(ResPartner, self).create(vals)




