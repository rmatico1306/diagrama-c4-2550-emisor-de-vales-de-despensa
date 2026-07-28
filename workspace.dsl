workspace "Plataforma de Vales de Despensa PROFINSA" "Arquitectura conceptual preliminar para la emisión y operación de monederos electrónicos de vales de despensa." {

    model {
        empresaCliente = person "Empresa cliente" {
            description "Empresa que contrata el servicio, registra colaboradores, solicita tarjetas y genera pedidos de dispersión."
            tags "Cliente"
        }

        beneficiario = person "Beneficiario" {
            description "Colaborador que recibe, activa y utiliza el monedero electrónico de vales de despensa."
            tags "Beneficiario"
        }

        operadorProfinsa = person "Operador PROFINSA" {
            description "Personal encargado de administrar clientes, beneficiarios, tarjetas, pedidos, dispersiones y aclaraciones."
            tags "Profinsa"
        }

        tesoreriaContabilidad = person "Tesorería y Contabilidad" {
            description "Personal que valida el pago del cliente antes de la autorización del pedido y consulta información financiera relacionada."
            tags "Profinsa"
        }

        atencionProfinsa = person "Responsable de atención PROFINSA" {
            description "Rol pendiente de definición encargado de atender solicitudes, bloqueos, aclaraciones e incidentes de clientes y beneficiarios."
            tags "Profinsa"
        }

        cumplimientoProfinsa = person "Responsable de cumplimiento PROFINSA" {
            description "Rol pendiente de definición encargado de preparar evidencias y atender el proceso de autorización y verificación ante el SAT."
            tags "Profinsa"
        }


        /************************************************************
         * SISTEMA PRINCIPAL
         ************************************************************/

        plataformaProfinsa = softwareSystem "Plataforma de Monedero Electrónico PROFINSA" {
            description "Plataforma que administra clientes, beneficiarios, pedidos, tarjetas, dispersiones, saldos de control, movimientos, conciliación, soporte y evidencias de cumplimiento."

            /********************************************************
             * CANALES
             ********************************************************/

            portalEmpresarial = container "Portal empresarial" {
                description "Permite a las empresas clientes administrar usuarios, colaboradores, tarjetas, pedidos de dispersión y reportes."
                technology "Aplicación web"
                tags "Web"
            }

            appBeneficiario = container "Aplicación del beneficiario" {
                description "Permite activar la tarjeta, consultar saldo y movimientos, bloquear el monedero y recibir notificaciones."
                technology "Aplicación móvil"
                tags "Mobile"
            }

            portalOperacion = container "Portal operativo PROFINSA" {
                description "Permite administrar clientes, contratos, pedidos, tarjetas, dispersiones, excepciones y conciliaciones."
                technology "Aplicación web"
                tags "Web"
            }


            /********************************************************
             * ENTRADA Y SEGURIDAD
             ********************************************************/

            apiGateway = container "API Gateway" {
                description "Punto de entrada para las aplicaciones; autentica, autoriza, limita y registra las solicitudes."
                technology "API Management / HTTPS"
                tags "API"
            }

            identidadAccesos = container "Gestión de identidad y acceso" {
                description "Administra usuarios, roles, autenticación multifactor, sesiones y políticas de acceso."
                technology "IAM / OAuth 2.0 / OpenID Connect"
                tags "Security"
            }


            /********************************************************
             * CORE DE NEGOCIO PROFINSA
             ********************************************************/

            coreNegocio = container "Core de negocio PROFINSA" {
                description "Gestiona clientes, beneficiarios, contratos, pedidos, autorizaciones internas, tarjetas y reglas comerciales."
                technology "Servicios backend"
                tags "Core"
            }

            servicioDispersiones = container "Servicio de dispersiones" {
                description "Valida, autoriza y ejecuta las instrucciones de dispersión hacia el procesador externo."
                technology "Servicio backend"
                tags "Core"
            }

            gestionTarjetas = container "Gestión de tarjetas" {
                description "Gestiona solicitudes, asociaciones, activaciones, bloqueos, reposiciones, cancelaciones y estados de tarjetas."
                technology "Servicio backend"
                tags "Core"
            }

            conciliacion = container "Motor de conciliación" {
                description "Compara pedidos, dispersiones, transacciones, saldos y registros contables para identificar diferencias."
                technology "Servicio backend / Procesamiento por lotes"
                tags "Core"
            }

            aclaraciones = container "Servicio de aclaraciones" {
                description "Gestiona compras no reconocidas, cargos duplicados, devoluciones, ajustes y seguimiento de casos."
                technology "Servicio backend"
                tags "Core"
            }

            reportes = container "Servicio de reportes" {
                description "Genera reportes operativos, financieros, transaccionales, comerciales y evidencias para auditoría."
                technology "Servicio de reportes"
                tags "Reporting"
            }

            notificaciones = container "Servicio de notificaciones" {
                description "Envía correos, mensajes SMS, notificaciones push y avisos operativos."
                technology "Correo / SMS / Push"
                tags "Integration"
            }


            /********************************************************
             * INTEGRACIONES
             ********************************************************/

            adaptadorProcesador = container "Adaptador del procesador" {
                description "Aísla al core de las APIs específicas del procesador y gestiona webhooks, reintentos, idempotencia y traducción de estados."
                technology "API REST / Webhooks / Archivos"
                tags "Integration"
            }

            integracionSap = container "Adaptador SAP" {
                description "Integra clientes, pedidos, pagos, facturación, comisiones y registros contables con SAP."
                technology "OData / API REST / Servicios SAP"
                tags "Integration"
            }

            integracionTarjetas = container "Adaptador del fabricante de tarjetas" {
                description "Envía órdenes de fabricación, personalización, envío y recepción de tarjetas."
                technology "API REST / SFTP / Archivos"
                tags "Integration"
            }

            busEventos = container "Bus de eventos" {
                description "Distribuye eventos de pedidos, dispersiones, tarjetas, transacciones, conciliaciones y notificaciones."
                technology "Mensajería asíncrona"
                tags "Messaging"
            }


            /********************************************************
             * DATOS
             ********************************************************/

            baseOperativa = container "Base de datos operativa" {
                description "Almacena clientes, contratos, usuarios, beneficiarios, pedidos, tarjetas, configuraciones y aclaraciones."
                technology "Base de datos relacional"
                tags "Database"
            }

            ledgerControl = container "Ledger de control PROFINSA" {
                description "Mantiene una réplica auditable de dispersiones, compras, reversos, devoluciones y ajustes para control y conciliación."
                technology "Base de datos transaccional"
                tags "Database,Ledger"
            }

            repositorioDocumental = container "Repositorio documental" {
                description "Almacena contratos, identificaciones, layouts, comprobantes, facturas y evidencias."
                technology "Almacenamiento de objetos"
                tags "Storage"
            }

            auditoriaLogs = container "Auditoría y logs centralizados" {
                description "Conserva registros protegidos de actividad, accesos, integraciones y operaciones críticas."
                technology "Logs inmutables / SIEM"
                tags "Security,Database"
            }
        }


        /************************************************************
         * SISTEMAS EXTERNOS
         ************************************************************/

        procesadorExterno = softwareSystem "Procesador externo de tarjetas" {
            description "Administra la emisión técnica, saldo operativo, autorizaciones, NIP, EMV, reversos, devoluciones y compensación."
            tags "External,Processor"
        }

        redPagos = softwareSystem "Red de pagos" {
            description "Red utilizada para enrutar y procesar las transacciones, por ejemplo Visa, Mastercard, Carnet u otra."
            tags "External,Network"
        }

        comerciosPos = softwareSystem "Comercios y terminales POS" {
            description "Establecimientos donde los beneficiarios realizan compras con el monedero."
            tags "External,Commerce"
        }

        sap = softwareSystem "SAP" {
            description "Sistema empresarial utilizado para clientes, facturación, contabilidad, cuentas por cobrar y conciliación."
            tags "External,SAP"
        }

        fabricanteTarjetas = softwareSystem "Fabricante y personalizador de tarjetas" {
            description "Fabrica, personaliza, empaqueta y entrega las tarjetas físicas."
            tags "External,Supplier"
        }

        servicioMensajeria = softwareSystem "Proveedor de mensajería" {
            description "Entrega correos, mensajes SMS y notificaciones push."
            tags "External,Supplier"
        }

        sat = softwareSystem "SAT" {
            description "Autoridad que autoriza y verifica el cumplimiento del emisor de monederos electrónicos."
            tags "External,Authority"
        }


        /************************************************************
         * RELACIONES DEL NIVEL 1 - CONTEXTO
         ************************************************************/

        empresaCliente -> plataformaProfinsa "Registra colaboradores, solicita tarjetas, genera dispersiones y consulta reportes" "HTTPS"

        beneficiario -> plataformaProfinsa "Activa y administra su monedero, consulta saldo y movimientos" "App móvil / HTTPS"

        operadorProfinsa -> plataformaProfinsa "Administra la operación del monedero" "HTTPS / MFA"

        tesoreriaContabilidad -> plataformaProfinsa "Valida el pago del cliente y consulta información financiera del pedido" "HTTPS / MFA"

        atencionProfinsa -> plataformaProfinsa "Atiende solicitudes, bloqueos, aclaraciones e incidentes" "HTTPS / MFA"

        cumplimientoProfinsa -> plataformaProfinsa "Consulta reportes y obtiene evidencias de cumplimiento" "HTTPS / MFA"

        cumplimientoProfinsa -> sat "Presenta documentación y atiende procesos de autorización y verificación" "Portal / Expediente documental"
        plataformaProfinsa -> procesadorExterno "Solicita emisión técnica, dispersiones, bloqueos y consulta movimientos" "API REST / Archivos"

        procesadorExterno -> plataformaProfinsa "Notifica compras, rechazos, reversos, devoluciones y cambios de estado" "Webhooks / Archivos"



        comerciosPos -> redPagos "Envía transacciones de compra, cancelación y devolución"

        redPagos -> procesadorExterno "Enruta solicitudes de autorización y mensajes transaccionales"

        procesadorExterno -> redPagos "Responde aprobaciones o rechazos"

        plataformaProfinsa -> sap "Envía pedidos, comisiones, facturas y movimientos contables" "API / OData"

        sap -> plataformaProfinsa "Proporciona clientes, pagos, facturas y registros contables" "API / OData"


        plataformaProfinsa -> fabricanteTarjetas "Envía órdenes de fabricación y personalización" "API / SFTP"

        plataformaProfinsa -> servicioMensajeria "Solicita el envío de notificaciones" "API"



        /************************************************************
         * RELACIONES DEL NIVEL 2 - CONTENEDORES
         ************************************************************/

        empresaCliente -> portalEmpresarial "Usa" "HTTPS"

        beneficiario -> appBeneficiario "Usa" "HTTPS"

        operadorProfinsa -> portalOperacion "Usa" "HTTPS / MFA"

        tesoreriaContabilidad -> portalOperacion "Usa" "HTTPS / MFA"

        cumplimientoProfinsa -> portalOperacion "Consulta reportes y evidencias" "HTTPS / MFA"

        atencionProfinsa -> portalOperacion "Atiende solicitudes, aclaraciones, bloqueos e incidentes" "HTTPS / MFA"

        portalEmpresarial -> apiGateway "Consume APIs" "HTTPS / JSON"

        appBeneficiario -> apiGateway "Consume APIs" "HTTPS / JSON"

        portalOperacion -> apiGateway "Consume APIs" "HTTPS / JSON"


        portalEmpresarial -> identidadAccesos "Autentica usuarios"
        appBeneficiario -> identidadAccesos "Autentica beneficiarios"
        portalOperacion -> identidadAccesos "Autentica operadores con MFA"

        apiGateway -> identidadAccesos "Valida identidades, sesiones y permisos"
        apiGateway -> coreNegocio "Invoca servicios de negocio"
        apiGateway -> gestionTarjetas "Invoca operaciones de tarjetas"
        apiGateway -> servicioDispersiones "Invoca operaciones de dispersión"
        apiGateway -> aclaraciones "Invoca operaciones de soporte y aclaraciones"
        apiGateway -> reportes "Solicita reportes"

        coreNegocio -> baseOperativa "Lee y escribe"
        coreNegocio -> repositorioDocumental "Almacena y consulta documentos"
        coreNegocio -> busEventos "Publica eventos de negocio"
        coreNegocio -> integracionSap "Solicita procesos empresariales"
        coreNegocio -> adaptadorProcesador "Solicita operaciones del procesador"
        coreNegocio -> auditoriaLogs "Registra actividades"

        servicioDispersiones -> baseOperativa "Consulta pedidos autorizados"
        servicioDispersiones -> ledgerControl "Registra instrucciones y movimientos de control"
        servicioDispersiones -> adaptadorProcesador "Envía instrucciones de dispersión"
        servicioDispersiones -> busEventos "Publica resultados de dispersión"
        servicioDispersiones -> auditoriaLogs "Registra actividades críticas"

        gestionTarjetas -> baseOperativa "Consulta y actualiza estados"
        gestionTarjetas -> adaptadorProcesador "Solicita emisión, activación, bloqueo y reposición"
        gestionTarjetas -> integracionTarjetas "Solicita fabricación y personalización"
        gestionTarjetas -> busEventos "Publica cambios de estado"
        gestionTarjetas -> auditoriaLogs "Registra operaciones de tarjeta"

        adaptadorProcesador -> procesadorExterno "Consume APIs de emisión y procesamiento" "HTTPS / API REST"

        procesadorExterno -> adaptadorProcesador "Envía eventos transaccionales" "Webhooks / Archivos"

        adaptadorProcesador -> ledgerControl "Registra compras, reversos y devoluciones"
        adaptadorProcesador -> busEventos "Publica eventos transaccionales"
        adaptadorProcesador -> auditoriaLogs "Registra solicitudes y respuestas"

        conciliacion -> ledgerControl "Consulta movimientos internos"
        conciliacion -> baseOperativa "Consulta pedidos y dispersiones"
        conciliacion -> adaptadorProcesador "Obtiene transacciones y saldos del procesador"
        conciliacion -> integracionSap "Obtiene registros contables"
        conciliacion -> auditoriaLogs "Registra resultados y diferencias"
        conciliacion -> busEventos "Publica diferencias de conciliación"

        aclaraciones -> baseOperativa "Registra y consulta casos"
        aclaraciones -> ledgerControl "Consulta transacciones relacionadas"
        aclaraciones -> adaptadorProcesador "Solicita reversos, devoluciones o investigaciones"
        aclaraciones -> repositorioDocumental "Almacena evidencias"
        aclaraciones -> busEventos "Publica cambios del caso"
        aclaraciones -> auditoriaLogs "Registra acciones"

        reportes -> baseOperativa "Consulta información operativa"
        reportes -> ledgerControl "Consulta movimientos y saldos de control"
        reportes -> auditoriaLogs "Consulta evidencia auditable"

        busEventos -> notificaciones "Entrega eventos notificables"
        notificaciones -> servicioMensajeria "Envía correos, SMS y notificaciones push" "API"

        integracionSap -> sap "Intercambia clientes, pagos, facturas y contabilidad" "OData / API"


        integracionTarjetas -> fabricanteTarjetas "Envía órdenes de fabricación y recibe estados" "API / SFTP"

        apiGateway -> auditoriaLogs "Registra accesos y solicitudes"
        identidadAccesos -> auditoriaLogs "Registra autenticaciones y cambios de permisos"
        portalOperacion -> auditoriaLogs "Registra acciones administrativas"
    }


    views {

        /************************************************************
         * C4 NIVEL 1 - CONTEXTO
         ************************************************************/

        systemContext plataformaProfinsa "C4-Nivel-1-Contexto" {
            description "Contexto de la Plataforma de Monedero Electrónico PROFINSA y sus relaciones con usuarios y sistemas externos."

            include empresaCliente
            include beneficiario
            include operadorProfinsa
            include tesoreriaContabilidad
            include atencionProfinsa
            include cumplimientoProfinsa

            include plataformaProfinsa
            include procesadorExterno
            include redPagos
            include comerciosPos
            include sap
            include fabricanteTarjetas
            include servicioMensajeria
            include sat

            autolayout lr
        }


        /************************************************************
         * C4 NIVEL 2 - CONTENEDORES
         ************************************************************/

        container plataformaProfinsa "C4-Nivel-2-Contenedores" {
            description "Contenedores principales de la Plataforma PROFINSA e integraciones con sistemas externos."

            include empresaCliente
            include beneficiario
            include operadorProfinsa
            include tesoreriaContabilidad
            include atencionProfinsa

            include portalEmpresarial
            include appBeneficiario
            include portalOperacion
            include apiGateway
            include identidadAccesos
            include coreNegocio
            include servicioDispersiones
            include gestionTarjetas
            include conciliacion
            include aclaraciones
            include reportes
            include notificaciones
            include adaptadorProcesador
            include integracionSap
            include integracionTarjetas
            include busEventos
            include baseOperativa
            include ledgerControl
            include repositorioDocumental
            include auditoriaLogs

            include procesadorExterno
            include redPagos
            include comerciosPos
            include sap
            include fabricanteTarjetas
            include servicioMensajeria

            autolayout lr
        }


        /************************************************************
         * ESTILOS
         ************************************************************/

        styles {

            element "Element" {
                shape RoundedBox
                background #F5F5F5
                color #1F2937
                stroke #6B7280
                fontSize 22
            }

            element "Person" {
                shape Person
                background #0B4F6C
                color #FFFFFF
                stroke #083B50
            }

            element "Cliente" {
                background #11698E
                color #FFFFFF
            }

            element "Beneficiario" {
                background #1A759F
                color #FFFFFF
            }

            element "Profinsa" {
                background #184E77
                color #FFFFFF
            }

            element "Software System" {
                background #2E6F95
                color #FFFFFF
                stroke #1F4E6B
            }

            element "Container" {
                background #BFD7EA
                color #102A43
                stroke #486581
            }

            element "Web" {
                shape WebBrowser
            }

            element "Mobile" {
                shape MobileDevicePortrait
            }

            element "API" {
                shape Hexagon
                background #89C2D9
            }

            element "Core" {
                background #61A5C2
                color #FFFFFF
            }

            element "Integration" {
                background #A9D6E5
                color #102A43
            }

            element "Messaging" {
                shape Pipe
                background #A9D6E5
            }

            element "Database" {
                shape Cylinder
                background #D9EAF2
                color #102A43
            }

            element "Ledger" {
                background #99D98C
                color #163A1B
            }

            element "Storage" {
                shape Folder
                background #D9EAF2
            }

            element "Security" {
                background #F4A261
                color #3D240B
            }

            element "Reporting" {
                background #E9C46A
                color #3D3106
            }

            element "External" {
                background #6B7280
                color #FFFFFF
                stroke #4B5563
            }

            element "Processor" {
                background #7B2CBF
                color #FFFFFF
            }

            element "Bank" {
                background #386641
                color #FFFFFF
            }

            element "Network" {
                background #9D4EDD
                color #FFFFFF
            }

            element "Commerce" {
                background #BC6C25
                color #FFFFFF
            }

            element "SAP" {
                background #0070F2
                color #FFFFFF
            }

            element "Supplier" {
                background #606C38
                color #FFFFFF
            }

            element "Authority" {
                background #9B2226
                color #FFFFFF
            }

            relationship "Relationship" {
                color #5B6770
                thickness 2
                routing Orthogonal
                fontSize 18
            }
        }

        theme default
    }

    configuration {
        scope softwaresystem
    }
}