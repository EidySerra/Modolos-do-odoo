{
    "name": "T Mola",
    "version": "1.0",
    "author": "Edvaldo, Olualinet",
    "summary": "Gestão de Oficina",
    "description": "Modolo de venda Herança",
    "depends": ['base', 'sale', 'product', 'sale_management'],
    "data": [
        'security/ir.model.access.csv',
        'data/sequence.xml',
        'data/sequence_mov.xml',
        'view/sale_view.xml',
        'view/res_partner_view.xml',
        'report/car_enter_out_report.xml',
        'view/product_view.xml',
        'view/car_enter_out_view.xml',
    ],
    "assets": {
        "web.assets_backend": [
            "t_mola_theme/static/src/css/t_mola_styles.css",
            # opcional JS:
            "t_mola_theme/static/src/js/t_mola_scripts.js",
        ],
        "web.assets_frontend": [
            "t_mola_theme/static/src/css/t_mola_styles.css",
        ]
    },
    "installable": True,
    "application": False,
}
