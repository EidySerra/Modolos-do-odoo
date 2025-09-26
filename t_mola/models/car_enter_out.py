from odoo import models, fields, api


class EnterOut(models.Model):
    _name = "car.enter.out"
    _description = "Entradas e Saídas de Carros"
    _rec_name = "name"

    name = fields.Char(
        string="Movimentação ID",
        readonly=True,
        copy=False,
        default="New"
    )
    car_id = fields.Many2one('sale.order', string="Carro")

    # Dados puxados automaticamente do sale.order
    partner_id = fields.Many2one(
        'res.partner',
        string="Nome do cliente",
        related="car_id.partner_id",
        store=True,
        readonly=True
    )
    # informacoees do cliente
    marca = fields.Char(
        string="Marca do carro",
        related="car_id.marca",
        store=True,
        readonly=True
    )
    matricula = fields.Char(
        string="Matricula do carro",
        related="car_id.matricula",
        store=True,
        readonly=True
    )
    color = fields.Char(
        string="Cor do carro",
        related="car_id.color",
        store=True,
        readonly=True
    )
    km = fields.Float(
        string="Kilometragem",
        related="car_id.km",
        store=True,
        readonly=True
    )
    chassi = fields.Integer(
        string="Numero do chassi",
        related="car_id.chassi",
        store=True,
        readonly=True
    )

    status = fields.Selection([
        ('entry', 'Entrada'),
        ('in_service', 'Em Serviço'),
        ('exit', 'Saída'),
        ('confirmed', 'Confirmado'),
        ('cancelled', 'Cancelado'),
    ], string="Status", default='entry', required=True)

    # ---- Ações da barra de estado ----
    def action_entry(self):
        for record in self:
            record.status = 'entry'
            record.entry_date = fields.Datetime.now()
            record.exit_date = False

    def action_in_service(self):
        for record in self:
            record.status = 'in_service'

    def action_exit(self):
        for record in self:
            record.status = 'exit'
            record.exit_date = fields.Datetime.now()

    # metodo para imprimir
    def action_print_card(self):
        return self.env.ref("t_mola.report_car_enter_out").report_action(self)

    # ---- Ações dos botões ----
    def action_confirm_email(self):
        for record in self:
            record.status = 'confirmed'
            # aqui pode integrar envio de email
        return True

    def action_confirm(self):
        for record in self:
            record.status = 'confirmed'
        return True

    def action_cancel(self):
        for record in self:
            record.status = 'cancelled'
        return True

    entry_date = (fields.Datetime(
    string="Data de Entrada",
    default = fields.Datetime.now,
    required = True ))

    exit_date = fields.Datetime(string="Data de Saída")
    note = fields.Text(string="Observações")

    @api.model
    def create(self, vals):
        if vals.get('name', 'New') == 'New':
            vals['name'] = self.env['ir.sequence'].next_by_code('car.enter.out.sequence') or 'New'
        return super(EnterOut, self).create(vals)
