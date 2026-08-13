workspace "Plataforma de Vales de Despensa PROFINSA" "Arquitectura C4 actualizada del MVP en AWS, sin dependencia de SAP y con facturación desde la plataforma mediante un PAC." {

    model {
        empresaCliente = person "Administrador / Manager del cliente" {
            description "Administra usuarios y accesos de la empresa cliente y consulta información operativa. No genera ni autoriza pedidos salvo que tenga un perfil operativo adicional."
            tags "Cliente"
        }

        generadorPedidoCliente = person "Usuario generador de pedido" {
            description "Registra beneficiarios, solicita tarjetas y genera pedidos de dispersión. No puede autorizar el mismo pedido."
            tags "Cliente"
        }

        autorizadorPedidoCliente = person "Usuario autorizador de pedido" {
            description "Revisa, autoriza o rechaza los pedidos generados por la empresa cliente antes de la emisión de la proforma."
            tags "Cliente"
        }

        beneficiario = person "Beneficiario" {
            description "Colaborador que recibe, activa y utiliza el monedero electrónico de vales de despensa."
            tags "Beneficiario"
        }

        operadorProfinsa = person "Operador PROFINSA" {
            description "Administra clientes, beneficiarios, tarjetas, pedidos, dispersiones, excepciones y conciliaciones."
            tags "Profinsa"
        }

        tesoreria = person "Tesorería PROFINSA" {
            description "Valida que el pago del cliente se encuentre reflejado en banco y asociado al cliente, folio, proforma e importe antes de facturar."
            tags "Profinsa"
        }

        responsableDispersionProfinsa = person "Responsable interno de dispersión PROFINSA" {
            description "Autoriza internamente la continuidad del pedido hacia dispersión una vez cumplidas las validaciones requeridas."
            tags "Profinsa"
        }

        contabilidad = person "Contabilidad y Facturación PROFINSA" {
            description "Supervisa la emisión, cancelación, sustitución y consulta de CFDI, notas de crédito y complementos de pago."
            tags "Profinsa"
        }

        atencionProfinsa = person "Atención PROFINSA" {
            description "Atiende solicitudes, bloqueos, aclaraciones e incidentes de clientes y beneficiarios."
            tags "Profinsa"
        }

        cumplimientoProfinsa = person "Cumplimiento y Seguridad PROFINSA" {
            description "Consulta evidencias, bitácoras, reportes y configuraciones para la autorización y verificación tecnológica ante el SAT."
            tags "Profinsa"
        }

        plataformaProfinsa = softwareSystem "Plataforma de Monedero Electrónico PROFINSA" {
            description "Sistema principal para clientes, beneficiarios, tarjetas, pedidos, pagos, facturación, dispersiones, ledger, conciliación, soporte, reportes y evidencias. No depende de SAP."

            portalEmpresarial = container "Portal empresarial" {
                description "Permite administrar usuarios y perfiles, registrar beneficiarios, consultar tarjetas, generar o autorizar pedidos según rol, consultar pagos, CFDI y reportes."
                technology "Aplicación web sobre Amazon CloudFront"
                tags "Web"
            }

            appBeneficiario = container "Aplicación del beneficiario" {
                description "Permite activación inicial, cambio y recuperación de NIP o contraseña, consulta de saldo y movimientos, desactivación temporal, reactivación de tarjeta y notificaciones."
                technology "Aplicación móvil"
                tags "Mobile"
            }

            portalOperacion = container "Portal operativo PROFINSA" {
                description "Permite operar clientes, validar pagos, gestionar facturación, autorizar internamente dispersiones, administrar tarjetas, conciliaciones, soporte y auditoría."
                technology "Aplicación web sobre Amazon CloudFront"
                tags "Web"
            }

            capaEntrada = container "Capa de entrada y protección" {
                description "Publica el portal y las APIs, termina TLS, filtra tráfico malicioso, aplica límites y distribuye solicitudes."
                technology "Amazon Route 53 + CloudFront + AWS WAF + ALB/API Gateway"
                tags "API,Security"
            }

            identidadAccesos = container "Identidad y control de acceso" {
                description "Gestiona usuarios, MFA, sesiones, recuperación de acceso, roles y segregación de funciones."
                technology "Amazon Cognito + IAM Identity Center"
                tags "Security"
            }

            coreNegocio = container "API y core de negocio" {
                description "Orquesta clientes, usuarios, beneficiarios, pedidos, autorizaciones, reglas comerciales y estados del proceso."
                technology "Django/Laravel API en Amazon ECS Fargate"
                tags "Core"

                clientesComponent = component "Gestión de clientes" {
                    description "Administra expediente, datos fiscales, condiciones comerciales y estatus del cliente."
                    technology "Módulo backend"
                }
                usuariosComponent = component "Usuarios y perfiles" {
                    description "Aplica RBAC, MFA y segregación de funciones entre Manager, generador, autorizador y consulta; impide que el generador autorice su propio pedido."
                    technology "Módulo backend"
                }
                beneficiariosComponent = component "Beneficiarios y layouts" {
                    description "Valida altas individuales y masivas, duplicados, campos obligatorios y relación con tarjetas."
                    technology "Módulo backend"
                }
                pedidosComponent = component "Pedidos y autorizaciones" {
                    description "Gestiona pedidos, folios, importes, fechas programadas, autorización o rechazo por el cliente y generación automática de proforma no timbrada."
                    technology "Módulo backend"
                }
                workflowComponent = component "Motor de estados y reglas" {
                    description "Controla los gates del proceso: pedido autorizado por el cliente, pago validado, facturación cuando aplique y autorización interna PROFINSA antes de dispersar."
                    technology "Servicio de dominio"
                }
                auditoriaComponent = component "Auditoría funcional" {
                    description "Genera eventos de trazabilidad con usuario, fecha, origen, acción y resultado."
                    technology "Servicio transversal"
                }
            }

            pagos = container "Servicio de pagos" {
                description "Gestiona estado de cuenta, comprobantes, referencias y validación del pago en firme por Tesorería."
                technology "Servicio backend en Amazon ECS Fargate"
                tags "Core"
            }

            facturacion = container "Servicio de facturación" {
                description "Construye CFDI, solicita timbrado al PAC, administra reintentos, cancelaciones, sustituciones, complementos y disponibilidad de PDF/XML."
                technology "Servicio backend y worker en Amazon ECS Fargate"
                tags "Core,Tax"

                fiscalDataComponent = component "Validador de datos fiscales" {
                    description "Valida RFC, razón social, código postal, régimen, uso CFDI, conceptos, impuestos, forma y método de pago."
                    technology "Componente de dominio"
                }
                cfdiBuilderComponent = component "Constructor de CFDI" {
                    description "Genera la solicitud fiscal y mantiene folio interno e idempotencia."
                    technology "Componente de dominio"
                }
                pacClientComponent = component "Cliente de integración PAC" {
                    description "Envía solicitudes, recibe UUID/XML, consulta estatus y procesa cancelaciones y sustituciones."
                    technology "Adaptador HTTPS/API"
                }
                invoiceWorkflowComponent = component "Workflow fiscal" {
                    description "Controla estados pendiente, enviado, timbrado, error, cancelado, sustituido y complemento emitido."
                    technology "Servicio de aplicación"
                }
                pdfComponent = component "Generador de representación PDF" {
                    description "Genera o recibe la representación impresa asociada al XML timbrado."
                    technology "Worker asíncrono"
                }
                fiscalAuditComponent = component "Auditoría fiscal" {
                    description "Registra cada operación de emisión, firmado, timbrado, descarga, cancelación y consulta."
                    technology "Servicio transversal"
                }
            }

            dispersiones = container "Servicio de dispersiones" {
                description "Verifica pedido autorizado por el cliente, pago validado y autorización interna PROFINSA; envía la instrucción al procesador y registra resultados, errores, reintentos e idempotencia."
                technology "Servicio backend y worker en Amazon ECS Fargate"
                tags "Core"

                dispersionValidationComponent = component "Validador previo a dispersión" {
                    description "Valida que el pedido esté autorizado, que el pago se encuentre validado y que exista autorización interna PROFINSA antes de continuar."
                    technology "Componente de dominio"
                }
                internalApprovalComponent = component "Autorización interna PROFINSA" {
                    description "Registra la decisión del responsable interno para autorizar la continuidad del pedido hacia dispersión, con usuario, fecha, hora y trazabilidad."
                    technology "Servicio de aplicación"
                }
                dispersionExecutionComponent = component "Ejecutor de dispersión" {
                    description "Construye y envía instrucciones de abono por beneficiario/tarjeta al procesador, con idempotencia y control de reintentos."
                    technology "Worker asíncrono"
                }
                dispersionStatusComponent = component "Control de resultados de dispersión" {
                    description "Gestiona estados pendiente, en proceso, aplicada, parcialmente aplicada y rechazada/con error; registra resultados por beneficiario."
                    technology "Servicio de dominio"
                }
            }

            tarjetas = container "Servicio de tarjetas" {
                description "Gestiona inventario de tarjetas por cliente, asignación automática a beneficiarios, activación, desactivación temporal, reactivación, bloqueo definitivo, reposición y trazabilidad sin exponer el PAN completo a usuarios operativos."
                technology "Servicio backend en Amazon ECS Fargate"
                tags "Core"

                cardInventoryComponent = component "Inventario de tarjetas por cliente" {
                    description "Mantiene tarjetas disponibles asignadas a cada cliente, tipo personalizada/stock, disponibilidad y estado operativo."
                    technology "Componente de dominio"
                }
                cardAssignmentComponent = component "Asignación automática de tarjetas" {
                    description "Asigna automáticamente una tarjeta disponible al beneficiario, evita doble asignación y garantiza una sola tarjeta activa por beneficiario."
                    technology "Servicio de aplicación"
                }
                cardLifecycleComponent = component "Ciclo de vida y reposición" {
                    description "Gestiona activación, desactivación temporal, reactivación, bloqueo definitivo y reposición; una nueva tarjeta se vincula al mismo beneficiario."
                    technology "Servicio de dominio"
                }
                cardDataProtectionComponent = component "Protección de datos de tarjeta" {
                    description "Expone a usuarios operativos solo identificadores mínimos o últimos cuatro dígitos; NIP, EMV y datos sensibles permanecen bajo control del procesador."
                    technology "Control transversal de seguridad"
                }
            }

            conciliacion = container "Motor de conciliación" {
                description "Compara pedidos, pagos, CFDI, dispersiones, transacciones y saldos para detectar diferencias."
                technology "Worker programado en Amazon ECS Fargate"
                tags "Core"
            }

            aclaraciones = container "Servicio de soporte y aclaraciones" {
                description "Gestiona casos, compras no reconocidas, cargos duplicados, devoluciones, reversos y evidencias."
                technology "Servicio backend en Amazon ECS Fargate"
                tags "Core"
            }

            reportes = container "Servicio de reportes y evidencias" {
                description "Genera reportes operativos, fiscales, transaccionales y evidencias para auditoría y SAT."
                technology "Worker/reporting en Amazon ECS Fargate"
                tags "Reporting"
            }

            adaptadorProcesador = container "Adaptador del procesador" {
                description "Aísla las APIs del procesador y gestiona webhooks, firmas, reintentos, idempotencia y traducción de estados."
                technology "Servicio de integración HTTPS/API/SFTP"
                tags "Integration"
            }

            adaptadorTarjetas = container "Adaptador del fabricante de tarjetas" {
                description "Envía órdenes de fabricación, personalización y entrega y recibe cambios de estado."
                technology "Servicio de integración API/SFTP"
                tags "Integration"
            }

            notificaciones = container "Servicio de notificaciones" {
                description "Envía correos, SMS y notificaciones push asociados a eventos operativos."
                technology "Amazon SES/SNS o proveedor externo"
                tags "Integration"
            }

            colasEventos = container "Colas y eventos" {
                description "Desacopla timbrado, dispersión, layouts, notificaciones, reportes, conciliación y reintentos."
                technology "Amazon SQS + Amazon EventBridge"
                tags "Messaging"
            }

            cache = container "Caché y control temporal" {
                description "Mantiene sesiones técnicas, rate limits, bloqueos e información temporal no maestra."
                technology "Amazon ElastiCache for Redis"
                tags "Database"
            }

            baseOperativa = container "Base de datos operativa" {
                description "Almacena clientes, usuarios, beneficiarios, pedidos, pagos, facturas, tarjetas, configuraciones y casos."
                technology "Amazon RDS PostgreSQL Multi-AZ"
                tags "Database"
            }

            ledgerControl = container "Ledger de control" {
                description "Mantiene movimientos inmutables de abono, compra, reverso, devolución, ajuste y saldo resultante para control y conciliación."
                technology "PostgreSQL con modelo de doble registro/control"
                tags "Database,Ledger"
            }

            repositorioDocumental = container "Repositorio documental" {
                description "Almacena expedientes, contratos, layouts, comprobantes, estados de cuenta, XML, PDF y evidencias."
                technology "Amazon S3 con KMS, versionado y retención"
                tags "Storage"
            }

            auditoriaLogs = container "Auditoría, monitoreo y seguridad" {
                description "Centraliza logs de aplicación, accesos y nube; genera alarmas y conserva evidencia protegida."
                technology "CloudWatch + CloudTrail + AWS Config + GuardDuty + Security Hub + S3 Object Lock"
                tags "Security,Database"
            }

            secretosLlaves = container "Secretos y llaves criptográficas" {
                description "Protege credenciales, llaves de integración y material sensible del proceso fiscal."
                technology "AWS Secrets Manager + AWS KMS"
                tags "Security"
            }
        }

        procesadorExterno = softwareSystem "Procesador externo de tarjetas" {
            description "Administra la emisión técnica, autorizaciones, saldo operativo, NIP/EMV, reversos, devoluciones y compensación."
            tags "External,Processor"
        }

        redPagos = softwareSystem "Red de pagos" {
            description "Enruta transacciones entre comercios y procesador."
            tags "External,Network"
        }

        comerciosPos = softwareSystem "Comercios y terminales POS" {
            description "Aceptan el monedero en compras autorizadas."
            tags "External,Commerce"
        }

        pac = softwareSystem "Proveedor Autorizado de Certificación (PAC)" {
            description "Valida, timbra, certifica y procesa operaciones fiscales de CFDI."
            tags "External,TaxProvider"
        }

        banco = softwareSystem "Banco / información bancaria" {
            description "Fuente para validar que el pago del cliente se encuentre reflejado. La validación puede apoyarse en integración, archivo o proceso manual controlado según el mecanismo definido."
            tags "External,Bank"
        }

        fabricanteTarjetas = softwareSystem "Proveedor de tarjetas físicas" {
            description "Fabrica, personaliza y entrega los plásticos conforme al proceso acordado. El mecanismo técnico de intercambio queda sujeto a definición con el proveedor."
            tags "External,Supplier"
        }

        servicioMensajeria = softwareSystem "Proveedor de mensajería" {
            description "Entrega correo, SMS o notificaciones push cuando no se utilicen servicios nativos de AWS."
            tags "External,Supplier"
        }

        sat = softwareSystem "SAT" {
            description "Autoridad que regula, autoriza y verifica el cumplimiento del emisor."
            tags "External,Authority"
        }

        empresaCliente -> plataformaProfinsa "Administra usuarios y perfiles y consulta información del cliente" "HTTPS"
        generadorPedidoCliente -> plataformaProfinsa "Registra beneficiarios, solicita tarjetas y genera pedidos de dispersión" "HTTPS"
        autorizadorPedidoCliente -> plataformaProfinsa "Revisa, autoriza o rechaza pedidos" "HTTPS"
        beneficiario -> plataformaProfinsa "Activa y administra su tarjeta y consulta saldo y movimientos" "App móvil / HTTPS"
        operadorProfinsa -> plataformaProfinsa "Administra la operación" "HTTPS / MFA"
        tesoreria -> plataformaProfinsa "Valida pagos reflejados en banco" "HTTPS / MFA"
        responsableDispersionProfinsa -> plataformaProfinsa "Autoriza internamente la continuidad hacia dispersión" "HTTPS / MFA"
        contabilidad -> plataformaProfinsa "Gestiona y supervisa CFDI" "HTTPS / MFA"
        atencionProfinsa -> plataformaProfinsa "Atiende solicitudes e incidentes" "HTTPS / MFA"
        cumplimientoProfinsa -> plataformaProfinsa "Consulta evidencias y bitácoras" "HTTPS / MFA"
        cumplimientoProfinsa -> sat "Presenta documentación y atiende verificaciones" "Portal / Expediente"

        plataformaProfinsa -> procesadorExterno "Solicita emisión, dispersión, bloqueo y consulta de transacciones" "HTTPS/API/SFTP"
        procesadorExterno -> plataformaProfinsa "Notifica compras, rechazos, reversos y estados" "Webhooks/Archivos"
        comerciosPos -> redPagos "Envía transacciones"
        redPagos -> procesadorExterno "Enruta autorizaciones"
        procesadorExterno -> redPagos "Responde aprobaciones o rechazos"
        plataformaProfinsa -> pac "Solicita timbrado, consulta, cancelación y sustitución de CFDI" "HTTPS/API"
        pac -> plataformaProfinsa "Entrega UUID, XML, estatus y acuses" "HTTPS/API/Webhook"
        plataformaProfinsa -> banco "Consulta, recibe o registra evidencia para validar pagos" "API/Archivo/Operación manual controlada"
        plataformaProfinsa -> fabricanteTarjetas "Intercambia órdenes y estados de tarjetas según mecanismo acordado" "Mecanismo por definir"
        plataformaProfinsa -> servicioMensajeria "Solicita notificaciones" "API"

        empresaCliente -> portalEmpresarial "Administra usuarios y consulta información" "HTTPS"
        generadorPedidoCliente -> portalEmpresarial "Registra beneficiarios y genera pedidos" "HTTPS"
        autorizadorPedidoCliente -> portalEmpresarial "Autoriza o rechaza pedidos" "HTTPS"
        beneficiario -> appBeneficiario "Usa" "HTTPS"
        operadorProfinsa -> portalOperacion "Usa" "HTTPS/MFA"
        tesoreria -> portalOperacion "Valida pagos" "HTTPS/MFA"
        responsableDispersionProfinsa -> portalOperacion "Autoriza continuidad hacia dispersión" "HTTPS/MFA"
        contabilidad -> portalOperacion "Gestiona CFDI" "HTTPS/MFA"
        atencionProfinsa -> portalOperacion "Gestiona casos" "HTTPS/MFA"
        cumplimientoProfinsa -> portalOperacion "Consulta evidencias" "HTTPS/MFA"

        portalEmpresarial -> capaEntrada "Consume portal y APIs" "HTTPS"
        appBeneficiario -> capaEntrada "Consume APIs" "HTTPS/JSON"
        portalOperacion -> capaEntrada "Consume portal y APIs" "HTTPS"
        capaEntrada -> identidadAccesos "Valida tokens, sesiones y permisos"
        capaEntrada -> coreNegocio "Enruta solicitudes de negocio"
        capaEntrada -> pagos "Enruta operaciones de pago"
        capaEntrada -> facturacion "Enruta consultas y operaciones fiscales"
        capaEntrada -> dispersiones "Enruta operaciones autorizadas"
        capaEntrada -> tarjetas "Enruta operaciones de tarjetas"
        capaEntrada -> aclaraciones "Enruta soporte y aclaraciones"
        capaEntrada -> reportes "Enruta consultas de reportes"
        capaEntrada -> auditoriaLogs "Registra solicitudes y eventos de seguridad"

        coreNegocio -> baseOperativa "Lee y escribe información maestra"
        coreNegocio -> repositorioDocumental "Gestiona expedientes y layouts"
        coreNegocio -> colasEventos "Publica eventos de negocio"
        coreNegocio -> auditoriaLogs "Registra trazabilidad"
        coreNegocio -> cache "Usa datos temporales y bloqueos"

        pagos -> baseOperativa "Gestiona estados y referencias de pago"
        pagos -> repositorioDocumental "Almacena estados de cuenta y comprobantes"
        pagos -> banco "Obtiene confirmación o referencia" "API/Archivo/Control manual"
        pagos -> colasEventos "Publica pago validado o rechazado"
        pagos -> auditoriaLogs "Registra validaciones"

        facturacion -> baseOperativa "Consulta pedidos/pagos y registra datos fiscales"
        facturacion -> repositorioDocumental "Almacena XML, PDF y acuses"
        facturacion -> pac "Solicita operaciones fiscales" "HTTPS/API"
        pac -> facturacion "Entrega resultados fiscales" "HTTPS/API/Webhook"
        facturacion -> secretosLlaves "Obtiene secretos y llaves autorizadas"
        facturacion -> colasEventos "Procesa timbrado, reintentos y complementos"
        facturacion -> auditoriaLogs "Registra operaciones fiscales"

        dispersiones -> baseOperativa "Consulta pedidos autorizados, pagos validados y autorización interna"
        dispersiones -> ledgerControl "Registra instrucciones y resultados"
        dispersiones -> adaptadorProcesador "Envía dispersiones"
        dispersiones -> colasEventos "Publica resultados y reintentos"
        dispersiones -> auditoriaLogs "Registra operaciones críticas"

        tarjetas -> baseOperativa "Gestiona relación y estado de tarjetas"
        tarjetas -> adaptadorProcesador "Solicita emisión, activación, bloqueo y reposición"
        tarjetas -> adaptadorTarjetas "Solicita fabricación y personalización"
        tarjetas -> colasEventos "Publica cambios de estado"
        tarjetas -> auditoriaLogs "Registra operaciones"

        adaptadorProcesador -> procesadorExterno "Consume servicios del procesador" "HTTPS/API/SFTP"
        procesadorExterno -> adaptadorProcesador "Envía eventos transaccionales" "Webhook/Archivo"
        adaptadorProcesador -> ledgerControl "Registra compras, reversos y devoluciones"
        adaptadorProcesador -> colasEventos "Publica eventos transaccionales"
        adaptadorProcesador -> auditoriaLogs "Registra solicitudes y respuestas"
        adaptadorProcesador -> secretosLlaves "Obtiene credenciales de integración"

        conciliacion -> baseOperativa "Consulta pedidos, pagos y CFDI"
        conciliacion -> ledgerControl "Consulta movimientos internos"
        conciliacion -> adaptadorProcesador "Obtiene transacciones y saldos"
        conciliacion -> colasEventos "Publica diferencias"
        conciliacion -> auditoriaLogs "Registra resultados"

        aclaraciones -> baseOperativa "Gestiona casos"
        aclaraciones -> ledgerControl "Consulta movimientos"
        aclaraciones -> adaptadorProcesador "Solicita investigación, reverso o devolución"
        aclaraciones -> repositorioDocumental "Almacena evidencias"
        aclaraciones -> auditoriaLogs "Registra acciones"

        reportes -> baseOperativa "Consulta información operativa y fiscal"
        reportes -> ledgerControl "Consulta saldos y movimientos"
        reportes -> repositorioDocumental "Genera y almacena evidencias"
        reportes -> auditoriaLogs "Consulta evidencia técnica"

        colasEventos -> notificaciones "Entrega eventos notificables"
        notificaciones -> servicioMensajeria "Envía mensajes" "API"
        adaptadorTarjetas -> fabricanteTarjetas "Intercambia órdenes y estados" "Mecanismo por definir"
        identidadAccesos -> auditoriaLogs "Registra autenticaciones y cambios de permisos"
        identidadAccesos -> secretosLlaves "Usa secretos y llaves administradas"

        clientesComponent -> baseOperativa "Lee y escribe expediente"
        clientesComponent -> repositorioDocumental "Gestiona documentación"
        usuariosComponent -> identidadAccesos "Provisiona y revoca accesos"
        usuariosComponent -> baseOperativa "Mantiene perfiles funcionales"
        beneficiariosComponent -> baseOperativa "Gestiona beneficiarios"
        beneficiariosComponent -> repositorioDocumental "Procesa layouts"
        pedidosComponent -> baseOperativa "Gestiona pedidos y proformas"
        pedidosComponent -> workflowComponent "Solicita validación de transición"
        workflowComponent -> pagos "Habilita seguimiento de pago"
        workflowComponent -> colasEventos "Publica cambios de estado"
        auditoriaComponent -> auditoriaLogs "Envía registros funcionales"
        workflowComponent -> dispersiones "Habilita dispersión solo al cumplir gates de negocio"

        dispersionValidationComponent -> baseOperativa "Consulta pedido y pago"
        dispersionValidationComponent -> internalApprovalComponent "Verifica autorización interna"
        responsableDispersionProfinsa -> internalApprovalComponent "Autoriza o rechaza continuidad" "HTTPS/MFA"
        internalApprovalComponent -> baseOperativa "Registra autorización y trazabilidad"
        internalApprovalComponent -> dispersionExecutionComponent "Habilita ejecución cuando autoriza"
        dispersionExecutionComponent -> adaptadorProcesador "Envía instrucciones de dispersión"
        dispersionExecutionComponent -> ledgerControl "Registra instrucción de abono"
        dispersionExecutionComponent -> dispersionStatusComponent "Entrega resultado de procesamiento"
        dispersionStatusComponent -> baseOperativa "Actualiza estatus y detalle por beneficiario"
        dispersionStatusComponent -> auditoriaLogs "Registra resultados y errores"

        beneficiariosComponent -> cardAssignmentComponent "Solicita asignación automática de tarjeta"
        cardAssignmentComponent -> cardInventoryComponent "Reserva tarjeta disponible del cliente"
        cardAssignmentComponent -> baseOperativa "Relaciona beneficiario y tarjeta"
        cardAssignmentComponent -> cardDataProtectionComponent "Aplica enmascaramiento para consulta"
        cardLifecycleComponent -> adaptadorProcesador "Solicita activación, desactivación, bloqueo o reposición"
        cardLifecycleComponent -> baseOperativa "Actualiza estado y relación de la tarjeta"
        cardInventoryComponent -> baseOperativa "Consulta y actualiza inventario de tarjetas"
        cardInventoryComponent -> adaptadorTarjetas "Gestiona altas/estados de plásticos disponibles"
        cardDataProtectionComponent -> adaptadorProcesador "Delega NIP, EMV y datos sensibles"
        cardDataProtectionComponent -> auditoriaLogs "Registra accesos y operaciones sensibles"

        fiscalDataComponent -> baseOperativa "Consulta datos fiscales y pedido"
        cfdiBuilderComponent -> fiscalDataComponent "Solicita datos validados"
        cfdiBuilderComponent -> pacClientComponent "Envía solicitud idempotente"
        pacClientComponent -> pac "Consume servicios fiscales" "HTTPS/API"
        pac -> pacClientComponent "Devuelve XML, UUID, estatus y acuses" "HTTPS/API/Webhook"
        pacClientComponent -> invoiceWorkflowComponent "Entrega resultado"
        invoiceWorkflowComponent -> baseOperativa "Actualiza estado fiscal"
        invoiceWorkflowComponent -> repositorioDocumental "Almacena XML y acuses"
        invoiceWorkflowComponent -> pdfComponent "Solicita representación PDF"
        pdfComponent -> repositorioDocumental "Almacena PDF"
        pacClientComponent -> secretosLlaves "Obtiene credenciales"
        fiscalAuditComponent -> auditoriaLogs "Registra evidencia fiscal"
    }

    views {
        systemContext plataformaProfinsa "C4-Nivel-1-Contexto" {
            description "Contexto actualizado según BBP: la plataforma es el sistema principal del emisor; integra procesador y PAC, y contempla validación bancaria por el mecanismo definido sin dependencia de SAP."
            include *
            autolayout lr
        }

        container plataformaProfinsa "C4-Nivel-2-Contenedores" {
            description "Contenedores del MVP en AWS para operación, pago, facturación, dispersión, seguridad y evidencia."
            include *
            autolayout lr
        }

        component coreNegocio "C4-Nivel-3-Core-Negocio" {
            description "Componentes internos del core para clientes, usuarios, beneficiarios, pedidos, reglas y trazabilidad."
            include *
            autolayout lr
        }

        component facturacion "C4-Nivel-3-Facturacion" {
            description "Componentes internos del servicio de facturación integrado con PAC y sin dependencia de SAP."
            include *
            autolayout lr
        }

        component tarjetas "C4-Nivel-3-Tarjetas" {
            description "Componentes para inventario por cliente, asignación automática, ciclo de vida, reposición y protección de datos de tarjeta según BBP."
            include *
            autolayout lr
        }

        component dispersiones "C4-Nivel-3-Dispersiones" {
            description "Componentes para validar pedido, pago y autorización interna PROFINSA antes de ejecutar y controlar la dispersión."
            include *
            autolayout lr
        }

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
            }
            element "Container" {
                background #BFD7EA
                color #102A43
            }
            element "Component" {
                background #E6F2F8
                color #102A43
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
            element "Tax" {
                background #2A9D8F
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
            }
            element "Processor" {
                background #7B2CBF
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
            element "TaxProvider" {
                background #2A9D8F
                color #FFFFFF
            }
            element "Bank" {
                background #386641
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
