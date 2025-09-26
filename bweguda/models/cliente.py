from odoo import models, fields, api


class Venda(models.Model):
    _inherit = "res.partner"

    customer_code = fields.Char(string="ID interno do cliente", requared=True, copy=False, readonly=True, index=True, default="New")

    @api.model
    def create(self, vals):
        if vals.get('customer_code', 'New') == 'New':
            vals['customer_code'] = self.env['ir.sequence'].next_by_code('res.partner.sequence') or 'New'
        return super(Venda, self).create(vals)
