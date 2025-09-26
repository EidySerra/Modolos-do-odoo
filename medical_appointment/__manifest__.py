{
    'name': 'Gestão de consultas medicas',
    'version': '1.0',
    'author': 'Edvaldo Serra, Olualinet',
    'summary': 'Desafio 2 gestão de consultas',
    'description': 'módulo completo e personalizado de gestão de clientes consultas medicas',
    'depends': ['base'],
    'data': [
        'security/ir.model.access.csv',
        'views/patient_views.xml',
        'views/doctor_views.xml',
        'views/appointment_views.xml'
    ],
    'assets': {
        'web.assets_backend':[
            'medical_appointment/static/src/estilo.css',
        ],
    },

    'installable': True,
    'aplication': True,
    'auto_instal': True,
}