# odoo-ao-partner-training
Treinamento Odoo para parceiros TICBLAC

# Script Odoo 18 + ubuntu 22.04 + Fail2Ban
chmod +x install-odoo18.sh

sudo ./install-odoo18.sh

# Odoo Partner Training - Custom Modules

Este repositório faz parte de um projeto de aprendizado e prática no desenvolvimento de módulos personalizados no **Odoo**, um dos ERPs de código aberto mais utilizados no mundo.

## 📦 Estrutura do Projeto

O projeto está dividido em diversos módulos customizados:

- `bweguda/`
- `edvaldo/`
- `medical_appointment/`

Cada pasta representa um módulo independente com suas próprias views, modelos e regras de segurança.

## 🔧 Funcionalidades Desenvolvidas

### 📄 Customização da View de Pedido de Venda (`sale.order`)

No módulo `bweguda`, foi realizada a herança da view padrão de pedidos de venda para adicionar uma nova aba chamada **"Aprovação"**, contendo o campo `approval_date`.

```xml
<page string="Aprovação">
  <group>
    <field name="approval_date"/>
  </group>
</page>
